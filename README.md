# Layerzero v2 Bridge Builder

This document explains how to deploy contracts on two chains using LayerZero's OFT (for ERC20) and ONFT (for ERC721) with `oftadapter` and `onftadapter` - check [here for Layerzero v2 documentation](https://docs.layerzero.network/v2/developers/evm/overview). These commands allow deploying two contracts on two separate blockchains for ERC20 and ERC721 tokens.

In the future, Layerzero will deploy also the adapter and the oft for ERC1155s, so for now, ERC1155 cannot be bridged with the lz-v2.

# Table of Contents

1. [Install dependencies](#install-dependencies)
2. [Before starting](#before-starting)
3. [Deploying an OFT Bridge (ERC20)](#deploying-an-oft-bridge-erc20)
4. [Deploying an ONFT Bridge (ERC721)](#deploying-an-onft-bridge-erc721)
5. [Deployed Examples](#deployed-examples)


---

## Install dependencies

To start, install the dependencies running `npm i`

## Before starting

This tool DOES NOT USES .env FILES TO STORE PRIVATE KEYS because it's so dangerous.

Instead, please import a wallet using cast ([need to install foundry first](https://book.getfoundry.sh/getting-started/installation)).

This way, your private key will be secure in a keystore and you'll use your account using a password.

Below the steps to import a wallet using _cast_:

```bash
cast wallet import <name of account> --interactive
*** put your pwd***
// now your pk is secure in a keystore
```

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

- beam oft: [0x09895fbd548404f5D19774dB8Dc45E3484d858a0](https://subnets-test.avax.network/beam/address/0x09895fbd548404f5D19774dB8Dc45E3484d858a0)
- sepolia oft adapter: [0x3E357dec7b680b11958e5aeCaEA9e3b036901e28](https://sepolia.etherscan.io/address/0x3E357dec7b680b11958e5aeCaEA9e3b036901e28)
