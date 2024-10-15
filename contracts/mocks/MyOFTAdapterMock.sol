// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {BeamOFTAdapter} from "../ERC20/BeamOFTAdapter.sol";

// @dev WARNING: This is for testing purposes only
contract MyOFTAdapterMock is BeamOFTAdapter {
    constructor(address _token, address _lzEndpoint, address _delegate)
        BeamOFTAdapter(_token, _lzEndpoint, _delegate)
    {}
}
