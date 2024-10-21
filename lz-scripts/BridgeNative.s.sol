// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script, console2} from "forge-std/Script.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {IOFT} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {MessagingFee} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import {NativeOFTAdapter} from
    "@layerzerolabs/toolbox-foundry/lib/devtools/packages/oft-evm/contracts/NativeOFTAdapter.sol";
import {LzConfig} from "../deploy/foundry/LzConfig.sol";
// import {OFTAdapter} from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
// import {BeamOFTAdapterNative} from "../contracts/native/BeamOFTAdapterNative.sol";
// this script is for bridging from sepolia to holesky

contract BridgeNative is Script {
    using OptionsBuilder for bytes;

    function bridgeNativeToken(uint256 destinationChainID, address adapter, address destinationAddress) public {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(destinationChainID);
        uint32 eid = lzContracts.eid;
        NativeOFTAdapter nativeAdapter = NativeOFTAdapter(adapter);

        uint256 amountToSendLD = 1 ether;
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        IOFT.SendParam memory sendParam =
            SendParam(eid, addressToBytes32(destinationAddress), amountToSendLD, amountToSendLD, options, "", "");
        MessagingFee memory fee = nativeAdapter.quoteSend(sendParam, false);

        uint256 correctMsgValue = fee.nativeFee + sendParam.amountLD;
        vm.startBroadcast();
        nativeAdapter.send{value: correctMsgValue}(sendParam, fee, destinationAddress);
        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
