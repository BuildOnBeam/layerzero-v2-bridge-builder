// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {BaseBeamOFTAdapter} from "./base/BaseBeamOFTAdapter.sol";

/**
 * @title OFTAdapter Contract
 * @dev OFTAdapter is a contract that adapts an ERC-20 token to the OFT functionality.
 *
 * @dev For existing ERC20 tokens, this can be used to convert the token to crosschain compatibility.
 * @dev WARNING: ONLY 1 of these should exist for a given global mesh,
 * unless you make a NON-default implementation of OFT and needs to be done very carefully.
 * @dev WARNING: The default OFTAdapter implementation assumes LOSSLESS transfers, ie. 1 token in, 1 token out.
 * IF the 'innerToken' applies something like a transfer fee, the default will NOT work...
 * a pre/post balance check will need to be done to calculate the amountSentLD/amountReceivedLD.
 */
contract BeamOFTAdapter is BaseBeamOFTAdapter {
    constructor(address _token, address _lzEndpoint, address _delegate, uint256 _feePercentage)
        BaseBeamOFTAdapter(_token, _lzEndpoint, _delegate, _feePercentage)
    {}
}
