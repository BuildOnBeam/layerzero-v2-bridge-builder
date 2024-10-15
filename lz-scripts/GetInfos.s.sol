// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script, console2} from "forge-std/Script.sol";
import {OAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";

// this script should be called after deployment of the OFT contracts
contract GetInfos is Script {
    //need to call this function with the eid of the other chain and the address of the contract on the other chain (the one we want to connect)
    function getInfos(address oftOrAdapter, uint32 eid) public {
        vm.startBroadcast();
        bytes32 peer = OAppCore(oftOrAdapter).peers(eid);
        console2.log("THE PEER for the eid %s is:",eid);
        console2.logBytes32(peer);
        vm.stopBroadcast();
    }
}
