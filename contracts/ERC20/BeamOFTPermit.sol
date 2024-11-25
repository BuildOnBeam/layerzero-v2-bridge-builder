// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {OFTPermit} from "contracts/lz-augmented/OFTPermit.sol";

contract BeamOFTPermit is OFTPermit {
    constructor(string memory _name, string memory _symbol, address _lzEndpoint, address _delegate)
        OFTPermit(_name, _symbol, _lzEndpoint, _delegate)
        Ownable(_delegate)
    {}
}
