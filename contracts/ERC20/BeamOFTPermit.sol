// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {BaseBeamOFT} from "./base/BaseBeamOFT.sol";

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract BeamOFTPermit is BaseBeamOFT, ERC20Permit {
    constructor(
        string memory _name,
        string memory _symbol,
        address _lzEndpoint,
        address _delegate,
        uint256 _feePercentage
    ) BaseBeamOFT(_name, _symbol, _lzEndpoint, _delegate, _feePercentage) ERC20Permit(_name) {}
}
