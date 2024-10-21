// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {BeamOFTNative} from "../../../contracts/native/BeamOFTNative.sol";
import {LzConfig} from "../LzConfig.sol";

/**
 * @notice This script deploy an OFT with the correct endpoint address
 * chainID is required to get the correct ENDPOINT_V2_ADDRESS
 * you're supposed to run this script and DeployBeamOFTAdapter
 */
contract DeployBeamOFTNative is Script {
    error DeployBeamOFT__ShouldNotBeBeamNetwork();

    /**
     * @notice deploy the contract
     * @param chainID chain id of the network to deploy the contract on
     * @param delegate the owner of the contract
     */
    function deployBeamOFTNative(uint256 chainID, address delegate) external {
        if (chainID == 13337 || chainID == 4337) {
            revert DeployBeamOFT__ShouldNotBeBeamNetwork();
        }

        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainID);
        address ENDPOINT_V2_ADDRESS = lzContracts.endpointV2;

        vm.startBroadcast();
        BeamOFTNative oft = new BeamOFTNative("Wrapped Beam", "wBEAM", ENDPOINT_V2_ADDRESS, delegate);
        vm.stopBroadcast();
        console2.log("Deployed contract at address:", address(oft));
    }
}
