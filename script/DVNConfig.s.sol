// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ILayerZeroEndpointV2} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";
import {SetConfigParam} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/IMessageLibManager.sol";
import {UlnConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/uln/UlnBase.sol";
import {ExecutorConfig} from "@layerzerolabs/lz-evm-messagelib-v2/contracts/SendLibBase.sol";
import {LzConfig} from "./LzConfig.sol";

contract DVNConfig is Script {
    uint32 constant EXECUTOR_CONFIG_TYPE = 1;
    uint32 constant ULN_CONFIG_TYPE = 2;

    function getConfig(address _oapp, uint32 _remoteChainId, bool _isSendConfig) public {
        uint256 chainId = block.chainid;
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainId);
        LzConfig.LzContracts memory lzContractsRemote = lzConfig.getLzContracts(_remoteChainId);

        uint32 remoteEid = lzContractsRemote.eid;
        address _endpoint = lzContracts.endpointV2;

        // Instantiate the LayerZero endpoint
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_endpoint);

        address lib;
        if (!_isSendConfig) {
            (lib,) = endpoint.getReceiveLibrary(_oapp, remoteEid);
        } else {
            lib = endpoint.getSendLibrary(_oapp, remoteEid);
        }

        // Retrieve the raw configuration bytes.
        bytes memory config = endpoint.getConfig(_oapp, lib, remoteEid, ULN_CONFIG_TYPE);

        /*
        if (_configType == EXECUTOR_CONFIG_TYPE) {
            // Decode the Executor config (configType = 1)
            ExecutorConfig memory execConfig = abi.decode(config, (ExecutorConfig));
            // Log some key configuration parameters.
            console.log("Executor Type:", execConfig.maxMessageSize);
            console.log("Executor Address:", execConfig.executor);
        }
        */

        // Decode the ULN config (configType = 2)
        UlnConfig memory decodedConfig = abi.decode(config, (UlnConfig));
        // Log some key configuration parameters.
        console.log("Confirmations:", decodedConfig.confirmations);
        console.log("Required DVN Count:", decodedConfig.requiredDVNCount);
        for (uint256 i = 0; i < decodedConfig.requiredDVNs.length; i++) {
            console.logAddress(decodedConfig.requiredDVNs[i]);
        }
        console.log("Optional DVN Count:", decodedConfig.optionalDVNCount);
        for (uint256 i = 0; i < decodedConfig.optionalDVNs.length; i++) {
            console.logAddress(decodedConfig.optionalDVNs[i]);
        }
        console.log("Optional DVN Threshold:", decodedConfig.optionalDVNThreshold);
    }

    function setConfig(address _oapp, uint32 _remoteChainId, bool _isSendConfig) external {
        uint256 chainId = block.chainid;
        LzConfig lzConfig = new LzConfig();
        LzConfig.LzContracts memory lzContracts = lzConfig.getLzContracts(chainId);
        LzConfig.LzContracts memory lzContractsRemote = lzConfig.getLzContracts(_remoteChainId);

        uint32 remoteEid = lzContractsRemote.eid;
        address _endpoint = lzContracts.endpointV2;

        // Instantiate the LayerZero endpoint
        ILayerZeroEndpointV2 endpoint = ILayerZeroEndpointV2(_endpoint);

        address lib;
        if (!_isSendConfig) {
            (lib,) = endpoint.getReceiveLibrary(_oapp, remoteEid);
        } else {
            lib = endpoint.getSendLibrary(_oapp, remoteEid);
        }

        UlnConfig memory uln = lzConfig.getSendConfig(chainId);
        if (!_isSendConfig) {
            UlnConfig memory ulnRemote = lzConfig.getSendConfig(_remoteChainId);
            uln.confirmations = ulnRemote.confirmations;
            uln.requiredDVNCount = ulnRemote.requiredDVNCount;
            uln.optionalDVNCount = ulnRemote.optionalDVNCount;
            uln.optionalDVNThreshold = ulnRemote.optionalDVNThreshold;
        }

        require(uln.requiredDVNCount == uln.requiredDVNs.length, "Required DVN count mismatch");
        require(
            (uln.optionalDVNCount == uln.optionalDVNs.length
                    || (uln.optionalDVNCount == lzConfig.NIL_DVN_COUNT() && uln.optionalDVNs.length == 0)),
            "Optional DVN count mismatch"
        );

        bytes memory encodedUln = abi.encode(uln);
        SetConfigParam[] memory params = new SetConfigParam[](1);
        params[0] = SetConfigParam(remoteEid, ULN_CONFIG_TYPE, encodedUln);

        bytes memory encodedParams = abi.encode(params);

        console.log("ILayerZeroEndpointV2:", _endpoint);
        console.log("ILayerZeroEndpointV2.setConfig(");
        console.log("    oapp: ", _oapp);
        console.log("    lib: ", lib);
        console.log("    params: ");
        console.logBytes(encodedParams);
        console.log(")");

        // vm.startBroadcast();
        // endpoint.setConfig(oapp, lib, params);
        // vm.stopBroadcast();
    }
}
