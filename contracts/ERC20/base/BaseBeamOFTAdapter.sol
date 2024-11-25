// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {OFTAdapter} from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title BaseBeamOFTAdapter Contract
 */

contract BaseBeamOFTAdapter is OFTAdapter {
    uint256 public s_feePercentage;
    uint256 public constant PRECISION = 1e18;

    constructor(address _token, address _lzEndpoint, address _delegate, uint256 _feePercentage)
        OFTAdapter(_token, _lzEndpoint, _delegate)
        Ownable(_delegate)
    {
        s_feePercentage = _feePercentage;
    }

    /**
     * @dev Internal function to mock the amount mutation from a OFT debit() operation.
     * @param _amountLD The amount to send in local decimals.
     * @param _minAmountLD The minimum amount to send in local decimals.
     * @dev _dstEid The destination endpoint ID.
     * @return amountSentLD The amount sent, in local decimals.
     * @return amountReceivedLD The amount to be received on the remote chain, in local decimals.
     *
     * @dev This is where things like fees would be calculated and deducted from the amount to be received on the remote.
     */
    function _debitView(uint256 _amountLD, uint256 _minAmountLD, uint32 /*_dstEid*/ )
        internal
        view
        virtual
        override
        returns (uint256 amountSentLD, uint256 amountReceivedLD)
    {
        // @dev Remove the dust so nothing is lost on the conversion between chains with different decimals for the token.
        amountSentLD = _removeDust(_amountLD);

        if (s_feePercentage > 0) {
            uint256 calculatedFees = (amountSentLD * s_feePercentage) / PRECISION;
            amountReceivedLD = amountSentLD - calculatedFees;
        } else {
            amountReceivedLD = amountSentLD;
        }

        // @dev Check for slippage.
        if (amountReceivedLD < _minAmountLD) {
            revert SlippageExceeded(amountReceivedLD, _minAmountLD);
        }
    }
}
