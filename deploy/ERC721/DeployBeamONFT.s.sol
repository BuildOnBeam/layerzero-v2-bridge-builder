// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Script, console2} from "forge-std/Script.sol";
import {BeamONFT721} from "../../../contracts/ERC721/BeamONFT721.sol";
import {LzConfig} from "../LzConfig.sol";

/**
 * @notice This script deploy an OFT with the correct endpoint address
 * chainID is required to get the correct ENDPOINT_V2_ADDRESS
 * you're supposed to run this script and DeployBeamOFTAdapter
 */
contract DeployBeamONFT is Script {
    /**
     * @notice deploy the contract
     * @param name name of the token
     * @param symbol symbol of the token
     * @param chainID chain id of the network to deploy the contract on
     * @param delegate the owner of the contract
     */
    function deployBeamONFT(string memory name, string memory symbol, uint256 chainID, address delegate) external {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainID);
        address ENDPOINT_V2_ADDRESS = lzContracts.endpointV2;

        vm.startBroadcast();
        BeamONFT721 onft = new BeamONFT721(name, symbol, ENDPOINT_V2_ADDRESS, delegate);
        vm.stopBroadcast();
        console2.log("Deployed contract at address:", address(onft));
    }
}
