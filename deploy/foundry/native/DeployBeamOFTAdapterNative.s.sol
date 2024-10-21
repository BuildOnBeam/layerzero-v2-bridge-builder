// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {BeamOFTAdapterNative} from "../../../contracts/native/BeamOFTAdapterNative.sol";
import {LzConfig} from "../LzConfig.sol";

/**
 * @notice
 * @notice
 */
contract DeployBeamOFTAdapterNative is Script {
    error DeployBeamOFTAdapter__NotBeamNetwork();

    /**
     * @notice deploy the contract
     * @param chainID chain id of the network to deploy the contract on
     * @param delegate the owner of the contract
     */
    function deployBeamOFTAdapterNative(uint256 chainID, address delegate) external {
        // you should deploy this contract just once, on BEAM network
        if (chainID != 13337 && chainID != 4337) {
            revert DeployBeamOFTAdapter__NotBeamNetwork();
        }

        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainID);
        address ENDPOINT_V2_ADDRESS = lzContracts.endpointV2;

        vm.startBroadcast();
        BeamOFTAdapterNative oftAdapter = new BeamOFTAdapterNative(18, ENDPOINT_V2_ADDRESS, delegate);
        vm.stopBroadcast();
        console2.log("Deployed contract at address:", address(oftAdapter));
    }
}
