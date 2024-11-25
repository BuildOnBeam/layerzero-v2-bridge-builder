// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {BaseBeamOFT} from "./base/BaseBeamOFT.sol";

contract BeamOFT is BaseBeamOFT {
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate,
        uint256 _feePercentage
    ) BaseBeamOFT(_name, _symbol, _lzEndpoint, _delegate, _feePercentage) {}
}
