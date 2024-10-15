// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

// Forge imports
import "forge-std/console.sol";
import "forge-std/Script.sol";

// LayerZero imports
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {LzConfig} from "../deploy/foundry/LzConfig.sol";

contract SetLibraries is Script {
    function setLibraries(address _oapp, uint256 _originChainID, uint256 _destinationChainID) external {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory originLzContracts = lzConfig.getLzContracts(_originChainID);
        LzConfig.LzContracts memory destinationLzContracts = lzConfig.getLzContracts(_destinationChainID);

        address originEndPoint = originLzContracts.endpointV2;
        address originSendLib = originLzContracts.sendUln302;
        address originReceiveLib = originLzContracts.receiveUln302;

        uint32 destinationEid = destinationLzContracts.eid;

        // Initialize the endpoint contract
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(originEndPoint);

        // Start broadcasting transactions
        vm.startBroadcast();

        // Set the send library
        endpoint.setSendLibrary(_oapp, destinationEid, originSendLib);
        console.log("Send library set successfully.");

        // Set the receive library
        endpoint.setReceiveLibrary(_oapp, destinationEid, originReceiveLib, 1);
        console.log("Receive library set successfully.");

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
