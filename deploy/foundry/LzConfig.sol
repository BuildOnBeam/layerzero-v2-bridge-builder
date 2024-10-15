// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract LzConfig {
    struct LzContracts {
        address executor;
        address endpointV2;
        address sendUln301;
        address sendUln302;
        address receiveUln301;
        address receiveUln302;
        uint32 eid;
    }

    mapping(uint256 chainID => LzContracts) public networkAddresses;

    constructor() {
        //TESTNETs
        // Sepolia-Testnet
        networkAddresses[11155111] = LzContracts({
            executor: 0x718B92b5CB0a5552039B593faF724D182A881eDA,
            endpointV2: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            sendUln301: 0x6862b19f6e42a810946B9C782E6ebE26Ad266C84,
            sendUln302: 0xcc1ae8Cf5D3904Cef3360A9532B477529b177cCE,
            receiveUln301: 0x5937A5fe272fbA38699A1b75B3439389EEFDb399,
            receiveUln302: 0xdAf00F5eE2158dD58E0d3857851c432E34A3A851,
            eid: 40161
        });

        // Beam-Testnet
        networkAddresses[13337] = LzContracts({
            executor: 0xA60A7a9D9723d6Adda826f5bDae29c6038B68DD3,
            endpointV2: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            sendUln301: 0x0e7C822d4dE804f648FD204139cf6d3fD943eBe4,
            sendUln302: 0x6f3a314C1279148E53f51AF154817C3EF2C827B1,
            receiveUln301: 0x36Ebea3941907C438Ca8Ca2B1065dEef21CCdaeD,
            receiveUln302: 0x0F7De6155DDC16A96c0d110A488bc966Aad3991b,
            eid: 40178
        });

        // Holesky-Testnet
        networkAddresses[17000] = LzContracts({
            executor: 0xBc0C24E6f24eC2F1fd7E859B8322A1277F80aaD5,
            endpointV2: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            sendUln301: 0xDD066F8c7592bf7235F314028E5e01a66F9835F0,
            sendUln302: 0x21F33EcF7F65D61f77e554B4B4380829908cD076,
            receiveUln301: 0x8d00218390E52B30d755882E09B2418eD08dCa7d,
            receiveUln302: 0xbAe52D605770aD2f0D17533ce56D146c7C964A0d,
            eid: 40217
        });

        // Fuji-Testnet
        networkAddresses[43113] = LzContracts({
            executor: 0xa7BFA9D51032F82D649A501B6a1f922FC2f7d4e3,
            endpointV2: 0x6EDCE65403992e310A62460808c4b910D972f10f,
            sendUln301: 0x184e24e31657Cf853602589fe5304b144a826c85,
            sendUln302: 0x69BF5f48d2072DfeBc670A1D19dff91D0F4E8170,
            receiveUln301: 0x91df17bF1Ced54c6169e1E24722C0a88a447cBAf,
            receiveUln302: 0x819F0FAF2cb1Fba15b9cB24c9A2BDaDb0f895daf,
            eid: 40106
        });

        // MAINNETs
        // Beam
        networkAddresses[4337] = LzContracts({
            executor: 0x9Bdf3aE7E2e3D211811E5e782a808Ca0a75BF1Fc,
            endpointV2: 0x1a44076050125825900e736c501f859c50fE728c,
            sendUln301: 0xB041cd355945627BDb7281f613B6E29623ab0110,
            sendUln302: 0x763BfcE1Ed335885D0EeC1F182fE6E6B85BAbC92,
            receiveUln301: 0x0b5E5452d0c9DA1Bb5fB0664F48313e9667d7820,
            receiveUln302: 0xe767e048221197A2b590CeB5C63C3AAD8ebf87eA,
            eid: 30198
        });

        //Ethereum
        networkAddresses[1] = LzContracts({
            executor: 0x173272739Bd7Aa6e4e214714048a9fE699453059,
            endpointV2: 0x1a44076050125825900e736c501f859c50fE728c,
            sendUln301: 0xD231084BfB234C107D3eE2b22F97F3346fDAF705,
            sendUln302: 0xbB2Ea70C9E858123480642Cf96acbcCE1372dCe1,
            receiveUln301: 0x245B6e8FFE9ea5Fc301e32d16F66bD4C2123eEfC,
            receiveUln302: 0xc02Ab410f0734EFa3F14628780e6e695156024C2,
            eid: 30101
        });

        // Avalanche
        networkAddresses[43114] = LzContracts({
            executor: 0x90E595783E43eb89fF07f63d27B8430e6B44bD9c,
            endpointV2: 0x1a44076050125825900e736c501f859c50fE728c,
            sendUln301: 0x31CAe3B7fB82d847621859fb1585353c5720660D,
            sendUln302: 0x197D1333DEA5Fe0D6600E9b396c7f1B1cFCc558a,
            receiveUln301: 0xF85eD5489E6aDd01Fec9e8D53cF8FAcFc70590BD,
            receiveUln302: 0xbf3521d309642FA9B1c91A08609505BA09752c61,
            eid: 30106
        });

        // Arbitrum
        networkAddresses[42161] = LzContracts({
            executor: 0x31CAe3B7fB82d847621859fb1585353c5720660D,
            endpointV2: 0x1a44076050125825900e736c501f859c50fE728c,
            sendUln301: 0x5cDc927876031B4Ef910735225c425A7Fc8efed9,
            sendUln302: 0x975bcD720be66659e3EB3C0e4F1866a3020E493A,
            receiveUln301: 0xe4DD168822767C4342e54e6241f0b91DE0d3c241,
            receiveUln302: 0x7B9E184e07a6EE1aC23eAe0fe8D6Be2f663f05e6,
            eid: 30110
        });

        // BNB
        networkAddresses[56] = LzContracts({
            executor: 0xACbD57daAafb7D9798992A7b0382fc67d3E316f3,
            endpointV2: 0x1a44076050125825900e736c501f859c50fE728c,
            sendUln301: 0xA2532E716E5c7755F567a74D75804D84d409DcDA,
            sendUln302: 0x44289609cc6781fa2C665796b6c5AAbf9FFceDC5,
            receiveUln301: 0x7807888fAC5c6f23F6EeFef0E6987DF5449C1BEb,
            receiveUln302: 0x9c9e25F9fC4e8134313C2a9f5c719f5c9F4fbD95,
            eid: 30202
        });
    }

    // Function to retrieve addresses for a given network
    function getLzContracts(uint256 chainID) external view returns (LzContracts memory) {
        return networkAddresses[chainID];
    }
}
