// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import { OFTAdapter } from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
import { BaseBeamBridge } from "./base/BaseBeamBridge.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BeamOFTAdapter
 * @notice Adapts an ERC-20 token to the OFT (Omnichain Fungible Token) functionality for cross-chain transfers.
 * @dev This contract wraps an existing ERC20 token to make it compatible with LayerZero's OFT, adding custom fee logic.
 * @dev **Important**: Only one instance of this adapter should exist for a given global token mesh due to the nature of OFT.
 * @dev **Warning**: Assumes lossless transfers. If the wrapped token (`innerToken`) applies fees or burns tokens,
 *        custom logic for calculating `amountSentLD` and `amountReceivedLD` would be required.
 */
contract BeamOFTAdapter is BaseBeamBridge, OFTAdapter {
    using SafeERC20 for IERC20;

    /**
     * @param _token The address of the ERC20 token to be adapted for OFT.
     * @param _lzEndpoint The LayerZero endpoint for cross-chain communication.
     * @param _delegate Address to delegate contract ownership.
     * @param _feePercentage The initial fee percentage to be charged on transactions. It should be in base 6: eg 1% would be 1e4
     */
    constructor(
        address _token,
        address _lzEndpoint,
        address _delegate,
        uint256 _feePercentage
    ) BaseBeamBridge(_feePercentage, _delegate) OFTAdapter(_token, _lzEndpoint, _delegate) {}

    /**
     * @notice Calculates the amount to send and receive considering custom fees.
     * @dev This function mocks the debit operation of OFTAdapter to calculate fees and amounts.
     * @param _amountLD The amount to send in local decimals.
     * @param _minAmountLD The minimum amount to receive on the destination chain.
     * @return amountSentLD The amount actually debited from the sender in local decimals.
     * @return amountReceivedLD The amount to be received on the remote chain after fees, in local decimals.
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
            amountReceivedLD = _amountLD;
            amountSentLD = _removeDust(_amountLD);
        }

        // @dev Check for slippage.
        if (amountReceivedLD < _minAmountLD) {
            revert SlippageExceeded(amountReceivedLD, _minAmountLD);
        }
    }

    /**
     * @notice Modifies the debit function to include custom fee handling.
     * @dev This function overrides the OFTAdapter's _debit to manage custom fees.
     * @param _from The address from which to debit tokens.
     * @param _amountLD The amount of tokens to send in local decimals.
     * @param _minAmountLD The minimum amount to receive on the destination chain.
     * @param _dstEid The destination endpoint ID.
     * @return amountSentLD The actual amount debited after fee application.
     * @return amountReceivedLD The amount to be received on the remote chain.
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
            innerToken.safeTransferFrom(_from, s_feeReceiver, customFee);
            innerToken.safeTransferFrom(_from, address(this), amountSentLD - customFee);
        } else {
            innerToken.safeTransferFrom(_from, address(this), amountReceivedLD);
        }
    }
}
