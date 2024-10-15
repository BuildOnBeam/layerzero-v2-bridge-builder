# Layerzero v2 Bridge Builder

This document explains the various commands in the Makefile and their usage. These commands are designed to deploy and manage bridge contracts, set peers, and interact with tokens on different chains using `foundry` and `cast`.

---

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

## Commands

### `deploy-bridge`

This command deploys the bridge contracts on two chains, using `RPC_URL_A` and `RPC_URL_B` to interact with two different networks.
This command deploys an _OFT_ and an _OFTAdapter_. This kind of bridge is needed to wrap existing ERC20 tokens on one chain and bridge them to another chain.

> Example: If I want to bridge LINKs from Ethereum Mainnet to Beam, I need to deploy an OFTAdapter contract on Ethereum to wrap LINKs in there, and an OFT contract on Beam.

- **Usage**:

  ```bash
  make deploy-bridge RPC_URL_A=<rpc_url_A> CHAIN_ID_A=<chain_id_A> ACCOUNT_NAME=<account> NAME=<name> SYMBOL=<symbol> DELEGATE=<delegate_address> RPC_URL_B=<rpc_url_B> CHAIN_ID_B=<chain_id_B> TOKEN=<token_address>
  ```

- **Parameters**:
  - `RPC_URL_A`: RPC URL of the first chain.
  - `CHAIN_ID_A`: Chain ID of the first chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `NAME`: Name of the OFT token.
  - `SYMBOL`: Symbol of the OFT token.
  - `DELEGATE`: Address of the contract owner or delegate.
  - `RPC_URL_B`: RPC URL of the second chain.
  - `CHAIN_ID_B`: Chain ID of the second chain.
  - `TOKEN`: ERC20 address of the token to bridge.

---

### `wire-bridge`

This command sets peers for both sides of the bridge, wiring the bridge between two chains.

- **Usage**:

  ```bash
  make wire-bridge RPC_URL_A=<rpc_url_A> CHAIN_ID_A=<chain_id_A> ACCOUNT_NAME=<account> RPC_URL_B=<rpc_url_B> CHAIN_ID_B=<chain_id_B> PEER_A=<peer_a_address> PEER_B=<peer_b_address>
  ```

- **Parameters**:
  - `RPC_URL_A`: RPC URL of the first chain.
  - `CHAIN_ID_A`: Chain ID of the first chain.
  - `RPC_URL_B`: RPC URL of the second chain.
  - `CHAIN_ID_B`: Chain ID of the second chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `PEER_A`: Contract address on chain A.
  - `PEER_B`: Contract address on chain B.

---

### `run-deploy-beam-oft`

Runs the deployment of an OFT (Omnichain Fungible Token) on a specified chain.

- **Usage**:

  ```bash
  make deploy-beam-oft RPC_URL=<rpc_url> ACCOUNT_NAME=<account> NAME=<name> SYMBOL=<symbol> CHAIN_ID=<chain_id> DELEGATE=<delegate_address>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `NAME`: Name of the OFT token.
  - `SYMBOL`: Symbol of the OFT token.
  - `CHAIN_ID`: Chain ID where the token is deployed.
  - `DELEGATE`: Address of the contract owner or delegate.

---

### `run-deploy-beam-oft-adapter`

Deploys an adapter for the OFT token.

- **Usage**:

  ```bash
  make deploy-beam-oft-adapter RPC_URL=<rpc_url> ACCOUNT_NAME=<account> CHAIN_ID=<chain_id> DELEGATE=<delegate_address> TOKEN=<token_address>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `CHAIN_ID`: Chain ID where the adapter is deployed.
  - `DELEGATE`: Address of the contract owner or delegate.
  - `TOKEN`: ERC20 address of the token to be adapted.

---

### `add-peer`

Adds a peer to the bridge contract on a given chain.

- **Usage**:

  ```bash
  make add-peer RPC_URL=<rpc_url> ACCOUNT_NAME=<account> CHAIN_ID=<chain_id> CONTRACT=<contract_address> PEER=<peer_address>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `CHAIN_ID`: Chain ID where the contract is deployed.
  - `CONTRACT`: Contract address of the bridge.
  - `PEER`: Address of the peer contract.

---

### `run-get-info`

Fetches information from a contract.

- **Usage**:

  ```bash
  make get-info RPC_URL=<rpc_url> EID=<event_id> CONTRACT=<contract_address>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `EID`: Event ID or other identifier.
  - `CONTRACT`: Contract address to fetch information from.

---

### `run-bridge-token`

Bridges tokens from one chain to another.

- **Usage**:

  ```bash
  make bridge-general RPC_URL=<rpc_url> ACCOUNT_NAME=<account> CHAIN_ID=<chain_id> CONTRACT=<contract_address>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `CHAIN_ID`: Chain ID of the destination chain.
  - `CONTRACT`: Contract address of the bridge.

---

### `run-set-libraries`

Sets library contracts on the bridge.

- **Usage**:

  ```bash
  make set-libraries RPC_URL=<rpc_url> ACCOUNT_NAME=<account> OAPP=<oapp_address> ORIGIN_CHAIN_ID=<origin_chain_id> DESTINATION_CHAIN_ID=<destination_chain_id>
  ```

- **Parameters**:
  - `RPC_URL`: RPC URL of the chain.
  - `ACCOUNT_NAME`: The account you'll sign the transaction with.
  - `OAPP`: Address of the application contract.
  - `ORIGIN_CHAIN_ID`: Chain ID of the origin chain.
  - `DESTINATION_CHAIN_ID`: Chain ID of the destination chain.

---

## General Notes

- The Makefile leverages environment variables to manage sensitive information like `ACCOUNT_PWD`, which can be stored in a `.env` file.
- For security, make sure to add `.env` to `.gitignore` to avoid exposing sensitive information.
