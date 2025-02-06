// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Script, console2} from "forge-std/Script.sol";
import {OAppCore} from "@layerzerolabs/oapp-evm/contracts/oapp/OAppCore.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";
import {SendParam} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {MessagingFee, MessagingReceipt} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import {BeamOFTAdapter} from "../contracts/ERC20/BeamOFTAdapter.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {LzConfig} from "../deploy/foundry/LzConfig.sol";
import "forge-std/console.sol";

// this script is for bridging from sepolia to holesky
contract BridgeToken is Script {
    using OptionsBuilder for bytes;

    function bridgeToken(
        uint256 destinationChainID,
        address oftOrAdapter,
        uint256 amountToBridge,
        address destinationAddress
    ) public {
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(destinationChainID);
        uint32 eid = lzContracts.eid;
        BeamOFTAdapter adapter = BeamOFTAdapter(oftOrAdapter);

        IERC20 tokenToBridge = IERC20(adapter.token());
        uint256 precision = adapter.PRECISION();
        console.log("precision");
        console.log(precision);
        uint256 feePercentage = adapter.s_feePercentage();
        console.log("feePercentage");
        console.log(feePercentage);
        uint256 tokensToSendIncludingFees = amountToBridge;
        // 100000000000000000 * 1000000 / 1000000

        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / precision;

        console.log("expectedFee");
        console.log(expectedFee);
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        console.log("tokenToSendMinusFees");
        console.log(tokenToSendMinusFees);

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

        SendParam memory sendParam = SendParam(
            eid, addressToBytes32(destinationAddress), tokensToSendIncludingFees, tokenToSendMinusFees, options, "", ""
        );
        MessagingFee memory fee = adapter.quoteSend(sendParam, false);

        vm.startBroadcast();
        tokenToBridge.approve(address(adapter), tokensToSendIncludingFees);
        adapter.send{value: fee.nativeFee}(sendParam, fee, payable(address(this)));

        vm.stopBroadcast();
    }

    function addressToBytes32(address _addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(_addr)));
    }
}
