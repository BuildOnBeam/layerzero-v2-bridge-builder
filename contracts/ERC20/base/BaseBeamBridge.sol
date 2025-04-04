// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { OFT } from "@layerzerolabs/oft-evm/contracts/OFT.sol";

/**
 * @title BaseBeamBridge
 * @notice This is a base contract inherited by BeamOFT and BeamOFTAdapter to manage cross-chain token transfers.
 */
abstract contract BaseBeamBridge is Ownable {
    error BaseBeamBridge__InvalidFeePercentage();
    error BaseBeamBridge__ZeroAddress();
    /// @dev The percentage of the fee charged on transfers, expressed in 1e6 precision.
    uint256 public s_feePercentage;

    /// @dev Constant for precision in calculations
    uint256 public constant PRECISION = 1e6;

    /// @dev Address where the fees collected are sent.
    address public s_feeReceiver;

    /// @dev see OFTCore.
    uint8 public immutable s_shareDecimals;

    /// @notice Emitted when the fee receiver address is set.
    event FeeReceiverSet(address indexed);

    /// @notice Emitted when the fee percentage is updated.
    event FeePercentageSet(uint256 indexed);

    /**
     * @dev Constructor for BaseBeamBridge.
     * @param _feePercentage Initial fee percentage for transactions, should be expressed with 1e6 precision. e.g., 1% would be 1e4
     * @param _delegate The address being delegated as the owner of this contract and initial fee receiver.
     */
    constructor(uint256 _feePercentage, address _delegate, uint8 _shareDecimals) Ownable(_delegate) {
        _setFeePercentage(_feePercentage);
        _setFeeReceiver(_delegate); 
        s_shareDecimals = _shareDecimals;
    }

    /**
     * @notice Sets the address that will receive fees from transactions.
     * @dev Can only be called by the current owner of the contract.
     * @param _feeReceiver The address to set as the new fee receiver.
     */
    function setFeeReceiver(address _feeReceiver) public onlyOwner {
        _setFeeReceiver(_feeReceiver);
    }

    /**
     * @notice Updates the fee percentage charged on transactions.
     * @dev Can only be called by the current owner. The percentage should be in 1e6 precision. e.g., 1% would be 1e4
     * @param _feePercentage The new fee percentage to set.
     */
    function setFeePercentage(uint256 _feePercentage) public onlyOwner {
        _setFeePercentage(_feePercentage);
    }

    /**
     * @dev Internal function to set the fee receiver address.
     * @param _feeReceiver The address to set as the new fee receiver.
     */
    function _setFeeReceiver(address _feeReceiver) internal {
        if (_feeReceiver == address(0)) {
            revert BaseBeamBridge__ZeroAddress();
        }
        s_feeReceiver = _feeReceiver;
        emit FeeReceiverSet(_feeReceiver);
    }

    /**
     * @dev Internal function to set the fee percentage.
     * @param _feePercentage The new fee percentage to set.
     */
    function _setFeePercentage(uint256 _feePercentage) internal {
        if (_feePercentage >= PRECISION) revert BaseBeamBridge__InvalidFeePercentage();
        s_feePercentage = _feePercentage;
        emit FeePercentageSet(_feePercentage);
    }
}
