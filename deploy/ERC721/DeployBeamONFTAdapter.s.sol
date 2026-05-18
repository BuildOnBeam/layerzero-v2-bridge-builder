// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {BeamONFT721Adapter} from "../../../contracts/ERC721/BeamONFT721Adapter.sol";

import {LzConfig} from "../LzConfig.sol";

/**
 * @notice
 * @notice
 */
contract DeployBeamONFTAdapter is Script {
    /**
     * @notice deploy the contract
     * @param chainID chain id of the network to deploy the contract on
     * @param delegate the owner of the contract
     * @param token existing ERC20 token to wrap
     */
    function deployBeamONFTAdapter(uint256 chainID, address delegate, address token) external {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainID);
        address ENDPOINT_V2_ADDRESS = lzContracts.endpointV2;

        vm.startBroadcast();
        BeamONFT721Adapter onftAdapter = new BeamONFT721Adapter(token, ENDPOINT_V2_ADDRESS, delegate);
        vm.stopBroadcast();
        console2.log("Deployed contract at address:", address(onftAdapter));
    }
}
