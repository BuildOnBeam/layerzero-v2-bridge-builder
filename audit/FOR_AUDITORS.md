# Beam Bridge Contracts

## Introduction

The Beam Bridge contracts extend LayerZero’s Omnichain Fungible Token (OFT) framework to enable cross-chain token transfers with an optional custom fee mechanism. This project includes two main implementations: `BeamOFT` (a native OFT token) and `BeamOFTAdapter` (an adapter for existing ERC20 tokens), both inheriting fee logic from `BaseBeamBridge`. The goal is to provide a flexible bridge solution that supports revenue generation by collecting fees on cross-chain transactions, redirecting them to a designated receiver (e.g., a treasury).

> **Note**: LayerZero’s `OFT.sol` and `OFTAdapter.sol` are not in scope for this audit. Auditors should understand the inherited `_debit` (handles token debiting) and `_removeDust` (adjusts amounts for precision) functions from LayerZero’s `OFTCore`. See [LayerZero OFT Docs](https://docs.layerzero.network/v2/developers/evm/oft/quickstart) for details.

## Audit Scope

Contracts to be audited are located in `contracts/ERC20/`:

- `base/BaseBeamBridge.sol`
- `BeamOFT.sol`
- `BeamOFTAdapter.sol`

### Contracts

#### `base/BaseBeamBridge.sol`

- **Description**: An abstract base contract inherited by `BeamOFT` and `BeamOFTAdapter`. It provides a reusable fee management system, allowing the owner to set a fee percentage (`s_feePercentage`, in 1e6 precision) and a fee receiver address (`s_feeReceiver`). Uses OpenZeppelin’s `Ownable` for access control.
- **Key Features**:
  - Configurable fee percentage (max 100%, enforced by `PRECISION`).
  - Events: `FeeReceiverSet`, `FeePercentageSet`.
  - Error: `BaseBeamBridge__InvalidFeePercentage`.
- **Purpose**: Abstracts fee logic for cross-chain transfers; does not handle token operations directly.

#### `BeamOFT.sol`

- **Description**: A native OFT token integrating LayerZero’s `OFT.sol` with custom fee logic. Inherits from `BaseBeamBridge`, `OFT`, `ERC20Permit` (gasless approvals), and `ERC20Burnable` (token burning). Fees are optionally deducted during cross-chain transfers, sent to `s_feeReceiver`, with the net amount burned.
- **Key Features**:
  - Custom `_debit` and `_debitView` logic for fee calculation and token burning.
  - Uses `SafeERC20` for secure transfers.
  - Supports slippage protection via `_minAmountLD`.
  - `ERC20Burnable` included for potential future burn-based logic.
- **Purpose**: A cross-chain ERC20 token with optional fees, paired with `BeamOFTAdapter` for broader compatibility.

#### `BeamOFTAdapter.sol`

- **Description**: Adapts an existing ERC20 token (`innerToken`) for LayerZero’s OFT framework via `OFTAdapter.sol`. Inherits from `BaseBeamBridge` and adds custom fee logic. Fees are collected and sent to `s_feeReceiver`, with the net amount held for cross-chain transfer.
- **Key Features**:
  - Custom `_debit` and `_debitView` for fee handling.
  - Assumes lossless `innerToken` transfers (warning: fee-on-transfer tokens require adjustments).
  - Single-instance design per token mesh (per LayerZero requirements).
- **Purpose**: Enables cross-chain functionality for non-OFT ERC20 tokens with a fee mechanism.

## Dependencies

- **Solidity Version**: `0.8.28`
- **External Libraries**:
  - OpenZeppelin Contracts (v5.x assumed): `Ownable`, `ERC20Permit`, `ERC20Burnable`, `SafeERC20`, `IERC20`.
  - LayerZero OFT (latest): `OFT.sol`, `OFTAdapter.sol`.
- Managed via Foundry remappings in `foundry.toml`.

## Setup & Test Instructions

1. **Install Dependencies**:

```bash
npm i
forge build
```

2. **run test and coverage**

```bash
make test-all # run all tests
make run-coverage # run coverage
```

## Security Notes

- **custom fees Receiver**: It could be a treasury multisig. Fees can be optionally set.
- **Precision**: Fee calculations may lose precision for small amounts due to integer division.




