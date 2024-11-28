# Layerzero v2 Bridge Builder

This document explains how to deploy contracts on two chains using LayerZero's OFT (for ERC20) and ONFT (for ERC721) with `oftadapter` and `onftadapter` - check [here for Layerzero v2 documentation](https://docs.layerzero.network/v2/developers/evm/overview). These commands allow deploying two contracts on two separate blockchains for ERC20 and ERC721 tokens.

In the future, Layerzero will deploy also the adapter and the oft for ERC1155s, so for now, ERC1155 cannot be bridged with the lz-v2.

# Table of Contents

1. [Install dependencies](#install-dependencies)
2. [Before starting](#before-starting)
3. [Using the CLI to deploy an ERC20 bridge](#using-the-cli-to-deploy-an-erc20-bridge)
4. [Deploying an OFT Bridge (ERC20)](#deploying-an-oft-bridge-erc20)
5. [Deploying an ONFT Bridge (ERC721)](#deploying-an-onft-bridge-erc721)
6. [Deployed Examples](#deployed-examples)
7. [Coverage](#coverage)

---

## Install dependencies

To start, install the dependencies running `npm i`

## Before starting (IMPORTANT)

ERC721 are not ready yet. For now only ERC20 are ok to go

### Deployer account and privkey security

This tool DOES NOT USES .env FILES TO STORE PRIVATE KEYS because it's so dangerous.

Instead, please import a wallet using cast ([need to install foundry first](https://book.getfoundry.sh/getting-started/installation)).

This way, your private key will be secure in a keystore and you'll use your account using a password.

Below the steps to import a wallet using _cast_:

```bash
cast wallet import <name of account> --interactive
*** put your pwd***
// now your pk is secure in a keystore
```

## Using the CLI to deploy an ERC20 bridge

### installation

You need to have Python installed on your system and install the required dependencies. Here's how to do it:

- **Install Python**: Ensure you have Python installed. You can download it from [python.org](https://www.python.org/downloads/) if it's not already installed.
- **Install Dependencies**: Navigate to the directory containing your Python scripts and install the dependencies by running:

`pip install -r requirements.txt`

### Usage

1. Print the command to deploy bridge

```bash
python3 print_deploy_command.py
```

> After running this command, you'll have printed a `make` command to be executed, like this:
> `make deploy-oft-bridge ACCOUNT_NAME=beam-test-1 NAME=TESTEN SYMBOL=TTEN DELEGATE=0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 PERCENTAGE=10000000000000000 IS_PERMIT=false RPC_URL_A=https://build.onbeam.com/rpc/testnet CHAIN_ID_A=13337 RPC_URL_B=https://ethereum-sepolia-rpc.publicnode.com CHAIN_ID_B=11155111 TOKEN=0x779877A7B0D9E8603169DdbD7836e478b4624789`

2. Execute the printed make command
   eg:

```bash
`make deploy-oft-bridge ACCOUNT_NAME=beam-test-1 NAME=TESTEN SYMBOL=TTEN DELEGATE=0x7f50CF0163B3a518d01fE480A51E7658d1eBeF87 PERCENTAGE=10000000000000000 IS_PERMIT=false RPC_URL_A=https://build.onbeam.com/rpc/testnet CHAIN_ID_A=13337 RPC_URL_B=https://ethereum-sepolia-rpc.publicnode.com CHAIN_ID_B=11155111 TOKEN=0x779877A7B0D9E8603169DdbD7836e478b4624789`
```

3. Print the command to wire the bridge

```bash
python3 print_wire_bridge_command.py
```

4. Execute the printed make command

```bash
make wire-bridge ACCOUNT_NAME=beam-test-1 RPC_URL_A=https://build.onbeam.com/rpc/testnet CHAIN_ID_A=13337 RPC_URL_B=https://ethereum-sepolia-rpc.publicnode.com CHAIN_ID_B=11155111 PEER_A=0x22D8346837BaF22Ade1502a66fa60b4810b2d2b5 PEER_B=0x9667d750C1A554C5D81E191a46C67991A923B841
```

> At this point you should have succesfully deploy the bridge.

## Deploying an OFT Bridge (ERC20)

This command deploys two contracts on two chains using the LayerZero OFT standard for ERC20 tokens with `oftadapter`.

<details>
  <summary><strong>Commands for Deploying an OFT Bridge (ERC20)</strong></summary>

### Command

```bash
make deploy-oft-bridge RPC_URL_A=<RPC url of chain where to deploy the oft token> CHAIN_ID_A=<chain id a> ACCOUNT_NAME=<your account> NAME=<name> SYMBOL=<symbol> DELEGATE=<the owner of the bridge> RPC_URL_B=<RPC url of chain where to deploy the adapter> CHAIN_ID_B=<chain id a> TOKEN=<address of token to wrap>
```

_then run_

```bash
make wire-bridge RPC_URL_A=<RPC url of chain where you deployed the oft token> CHAIN_ID_A=<chain id a> ACCOUNT_NAME=<your account> RPC_URL_B=<RPC url of chain whereyou deployed the oft adapter> CHAIN_ID_B=<chain id b> PEER_A=<contract deployed on chain A>  PEER_B=<contract deployed on chain B>
```

### E2E test

```bash
make test-bridge RPC_URL=<RPC of the chain where I want to initiate the bridge> ACCOUNT_NAME=<your account> CONTRACT=<the contract of the OFT or OFTAdapter> CHAIN_ID=<Chain id of the network>
```

</details>

---

## Deploying an ONFT Bridge (ERC721)

This command deploys two contracts on two chains using the LayerZero ONFT standard for ERC721 tokens with `onftadapter`.

<details>
  <summary><strong>Commands for Deploying an ONFT Bridge (ERC721)</strong></summary>

### Command

```bash
make deploy-onft-bridge RPC_URL_A=<RPC url of chain where to deploy the onft token> CHAIN_ID_A=<chain id a> ACCOUNT_NAME=<your account> NAME=<name> SYMBOL=<symbol> DELEGATE=<the owner of the bridge> RPC_URL_B=<RPC url of chain where to deploy the onft adapter> CHAIN_ID_B=<chain id a> TOKEN=<address of NFT token to wrap>
```

_then run_

```bash
make wire-bridge RPC_URL_A=<RPC url of chain where you deployed the onft token> CHAIN_ID_A=<chain id a> ACCOUNT_NAME=<your account> RPC_URL_B=<RPC url of chain whereyou deployed the onft adapter> CHAIN_ID_B=<chain id b> PEER_A=<contract deployed on chain A>  PEER_B=<contract deployed on chain B>
```

### E2E test

> That is coming soon

</details>

## Deployed Examples

### ERC721

- deployed a mock NFT on sepolia: [0x75163daF35891308c3298F5d5898B1d09c7aC5F3](https://sepolia.etherscan.io/address/0x75163daF35891308c3298F5d5898B1d09c7aC5F3)
- onft on beam: [0xF5e30876DB81A0BFee35048c0F69b53Fc1f30660](https://subnets-test.avax.network/beam/address/0xF5e30876DB81A0BFee35048c0F69b53Fc1f30660)
- onft adapter on sepolia: [0x1b39C6BD162bfd0C1d8F8184fc2b4198a99ff56F](https://sepolia.etherscan.io/address/0x1b39C6BD162bfd0C1d8F8184fc2b4198a99ff56F)

### ERC20

- beam oft: [0x87ceb22aC24FB14C4f3191C8DB974A0Be41e0aB8](https://subnets-test.avax.network/beam/address/0x87ceb22aC24FB14C4f3191C8DB974A0Be41e0aB8)
- sepolia oft adapter: [0x40f76105e01fbCA5fDc9E8897E7B69Fa71550C9d](https://sepolia.etherscan.io/address/0x40f76105e01fbCA5fDc9E8897E7B69Fa71550C9d)

## Coverage

to run test coverage:

```bash
make coverage
```

current coverage:
| File | % Lines | % Statements | % Branches | % Funcs |
|-----------------------------------------|-----------------|-----------------|-----------------|---------------|
| contracts/ERC20/BeamOFT.sol | 100.00% (14/14) | 100.00% (16/16) | 100.00% (5/5) | 100.00% (3/3) |
| contracts/ERC20/BeamOFTAdapter.sol | 100.00% (14/14) | 100.00% (16/16) | 100.00% (5/5) | 100.00% (3/3) |
| contracts/ERC20/base/BaseBeamBridge.sol | 100.00% (7/7) | 100.00% (8/8) | 100.00% (1/1) | 100.00% (3/3) |
| Total | 100.00% (35/35) | 100.00% (40/40) | 100.00% (11/11) | 100.00% (9/9) |
