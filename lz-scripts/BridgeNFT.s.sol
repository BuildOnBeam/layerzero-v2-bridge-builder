// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.22;

// import {Script, console2} from "forge-std/Script.sol";
// import {OAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";
// import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
// import {SendParam} from "@layerzerolabs/onft-evm/contracts/onft721/interfaces/IONFT721.sol";

// import {MessagingFee, MessagingReceipt} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
// import {OFTAdapter} from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
// import {OFTAdapter} from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";
// import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
// import {LzConfig} from "../deploy/foundry/LzConfig.sol";
// import {BeamONFT721Adapter} from "../contracts/ERC721/BeamONFT721Adapter.sol";

// // this script is for bridging from sepolia to holesky
// contract BridgeToken is Script {
//     // using IONFT721 for IONFT721.SendParam;
//     using OptionsBuilder for bytes;

//     function bridgeNFT(uint256 destinationChainID, address oftOrAdapter) public {
//         address destinationAddress = 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87;
//         LzConfig lzConfig = new LzConfig();
//         LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(destinationChainID);
//         uint32 eid = lzContracts.eid;
//         BeamONFT721Adapter adapter = BeamONFT721Adapter(oftOrAdapter);

//         IERC20 tokenToBridge = IERC20(adapter.token());

//         uint256 tokensToSend = 1 ether;
//         bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

//         SendParam memory sendParam =
//             SendParam(eid, addressToBytes32(destinationAddress), 1, tokensToSend, options, "", "");
//         MessagingFee memory fee = adapter.quoteSend(sendParam, false);

//         vm.startBroadcast();
//         // tokenToBridge.approve(address(adapter), tokensToSend);
//         adapter.send{value: fee.nativeFee}(sendParam, fee, payable(address(this)));

//         vm.stopBroadcast();
//     }

//     function bridgeToken(uint256 destinationChainID, address oftOrAdapter) public {
//         address destinationAddress = 0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87;
//         LzConfig lzConfig = new LzConfig();
//         LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(destinationChainID);
//         uint32 eid = lzContracts.eid;
//         OFTAdapter adapter = OFTAdapter(oftOrAdapter);

//         IERC20 tokenToBridge = IERC20(adapter.token());

//         uint256 tokensToSend = 1 ether;
//         bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

//         SendParam memory sendParam =
//             SendParam(eid, addressToBytes32(destinationAddress), tokensToSend, tokensToSend, options, "", "");
//         MessagingFee memory fee = adapter.quoteSend(sendParam, false);

//         vm.startBroadcast();
//         tokenToBridge.approve(address(adapter), tokensToSend);
//         adapter.send{value: fee.nativeFee}(sendParam, fee, payable(address(this)));

//         vm.stopBroadcast();
//     }

//     function addressToBytes32(address _addr) internal pure returns (bytes32) {
//         return bytes32(uint256(uint160(_addr)));
//     }
// }
