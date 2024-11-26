// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {BeamOFTAdapter} from "../../../contracts/ERC20/BeamOFTAdapter.sol";
import {LzConfig} from "../LzConfig.sol";

/**
 * @notice
 * @notice
 */
contract DeployBeamOFTAdapter is Script {
    /**
     * @notice deploy the contract
     * @param chainID chain id of the network to deploy the contract on
     * @param delegate the owner of the contract
     * @param token existing ERC20 token to wrap
     */
    function deployBeamOFTAdapter(uint256 chainID, address delegate, address token, uint256 percentage) external {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainID);
        address ENDPOINT_V2_ADDRESS = lzContracts.endpointV2;

        vm.startBroadcast();
        BeamOFTAdapter oftAdapter = new BeamOFTAdapter(token, ENDPOINT_V2_ADDRESS, delegate, percentage);
        vm.stopBroadcast();
        console2.log("Deployed contract at address:", address(oftAdapter));
    }
}
