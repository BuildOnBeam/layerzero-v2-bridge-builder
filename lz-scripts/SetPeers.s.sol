// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script, console2} from "forge-std/Script.sol";
import {OAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";
import {LzConfig} from "../deploy/foundry/LzConfig.sol";

// this script should be called after deployment of the OFT contracts
contract SetPeers is Script {
    //need to call this function with the eid of the other chain and the address of the contract on the other chain (the one we want to connect)
    function runSetPeer(uint256 destinationChainID, address oftOrAdapter, address peer) public {
        bytes32 peerInBytes = addressToBytes32(peer);
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(destinationChainID);
        uint32 eid = lzContracts.eid;

        vm.startBroadcast();
        OAppCore(oftOrAdapter).setPeer(eid, peerInBytes);
        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
