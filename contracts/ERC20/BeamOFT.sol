// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { BaseBeamBridge } from "./base/BaseBeamBridge.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { ERC20Burnable } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";

/**
 * @title BeamOFT
 * @notice An OFT (Omnichain Fungible Token) contract with custom _debit logic.
 * @dev This contract combines the functionality of ERC20Permit, OFT, and custom fee handling from BaseBeamBridge.
 */
contract BeamOFT is BaseBeamBridge, OFT, ERC20Permit, ERC20Burnable {
    using SafeERC20 for IERC20;

    /**
     * @notice Constructor for BeamOFT.
     * @param _name The name of the token.
     * @param _symbol The token symbol.
     * @param _lzEndpoint The LayerZero endpoint for cross-chain communication.
     * @param _delegate Address to delegate contract ownership.
     * @param _feePercentage The initial fee percentage to be charged on transactions.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate,
        uint256 _feePercentage
    ) OFT(_name, _symbol, _lzEndpoint, _delegate) BaseBeamBridge(_feePercentage, _delegate) ERC20Permit(_name) {}

    /**
     * @notice override _debitView on {OFT}
     * @param _amountLD The amount to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @dev _dstEid The destination endpoint ID.
     * @return amountSentLD The amount sent, in local decimals.
     * @return amountReceivedLD The amount to be received on the remote chain, in local decimals.
     */
    function _debitView(
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 /*_dstEid*/
    ) internal view virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {
        amountSentLD = _amountLD;
        if (s_feePercentage > 0) {
            uint256 calculatedFees = (_amountLD * s_feePercentage) / PRECISION;

            amountReceivedLD = _removeDust(_amountLD - calculatedFees);
        } else {
            amountSentLD = _removeDust(_amountLD);
            amountReceivedLD = amountSentLD;
        }

        // @dev Check for slippage.
        if (amountReceivedLD < _minAmountLD) {
            revert SlippageExceeded(amountReceivedLD, _minAmountLD);
        }
    }

    /**
     * @notice this function modify _debit in OFT contract to send custom fees to a fee receiver
     * @notice override _debitView on {OFT}
     * @dev inherit from OFT
     * @param _from The address to debit the tokens from.
     * @param _amountLD The amount of tokens to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @param _dstEid The destination chain ID.
     * @return amountSentLD The amount sent in local decimals.
     * @return amountReceivedLD The amount received in local decimals on the remote.
     */
    function _debit(
        address _from,
        uint256 _amountLD,
        uint256 _minAmountLD,
        uint32 _dstEid
    ) internal virtual override returns (uint256 amountSentLD, uint256 amountReceivedLD) {
        (amountSentLD, amountReceivedLD) = _debitView(_amountLD, _minAmountLD, _dstEid);

        // @dev Burn OFT and send custom fees to fee receiver if custom fees are enabled
        if (s_feePercentage > 0) {
            uint256 customFee = _amountLD - amountReceivedLD;
            IERC20(address(this)).safeTransferFrom(_from, s_feeReceiver, customFee);
            _burn(_from, amountSentLD - customFee);
        } else {
            _burn(_from, amountSentLD);
        }
    }
}
