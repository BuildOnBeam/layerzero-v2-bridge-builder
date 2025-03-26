// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Mock imports

import { BeamOFTAdapter } from "../../contracts/ERC20/BeamOFTAdapter.sol";
import { BaseBeamBridge } from "../../contracts/ERC20/base/BaseBeamBridge.sol";
import { BeamOFT } from "../../contracts/ERC20/BeamOFT.sol";
import { OFTMock } from "../mocks/OFTMock.sol";
import { IOFT } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";

import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { OFTComposerMock } from "../mocks/OFTComposerMock.sol";

// OApp imports
import { IOAppOptionsType3, EnforcedOptionParam } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import { OptionsBuilder } from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

// OFT imports
import { IOFT, SendParam, OFTReceipt } from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import { MessagingFee, MessagingReceipt } from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import { OFTMsgCodec } from "@layerzerolabs/oft-evm/contracts/libs/OFTMsgCodec.sol";
import { OFTComposeMsgCodec } from "@layerzerolabs/oft-evm/contracts/libs/OFTComposeMsgCodec.sol";

// OZ imports
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Forge imports
import "forge-std/console.sol";

// DevTools imports
import { TestHelperOz5 } from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

contract BeamBridgeTest is TestHelperOz5 {
    using OptionsBuilder for bytes;

    uint32 private aEid = 1;
    uint32 private bEid = 2;

    ERC20Mock private aToken;
    BeamOFTAdapter private aOFTAdapter;
    OFTMock private bOFT;
    uint256 userAPk = 0x1;
    uint256 userBPk = 0x2;
    uint256 userCPk = 0x3;
    uint256 userDPk = 0x4;
    address private userA = vm.addr(userAPk);
    address private userB = vm.addr(userBPk);
    address private userFeeReceiver = vm.addr(userCPk);
    address private userD = vm.addr(userDPk);
    uint256 private initialBalance = 100 ether;
    uint256 feePercentage = 5e4; //5%
    uint256 public constant PRECISION = 1e6;

    function setUp() public virtual override {
        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);
        vm.deal(userD, 1000 ether);

        super.setUp();
        setUpEndpoints(2, LibraryType.UltraLightNode);

        aToken = ERC20Mock(_deployOApp(type(ERC20Mock).creationCode, abi.encode("Token", "TOKEN")));

        aOFTAdapter = BeamOFTAdapter(
            _deployOApp(
                type(BeamOFTAdapter).creationCode,
                abi.encode(address(aToken), address(endpoints[aEid]), address(this), feePercentage)
            )
        );

        bOFT = OFTMock(
            _deployOApp(
                type(OFTMock).creationCode,
                abi.encode("Token", "TOKEN", address(endpoints[bEid]), address(this), feePercentage)
            )
        );
        vm.label(address(bOFT), "bOFT");
        vm.label(address(aOFTAdapter), "aOFTAdapter");
        // config and wire the ofts
        address[] memory ofts = new address[](2);
        ofts[0] = address(aOFTAdapter);
        ofts[1] = address(bOFT);
        this.wireOApps(ofts);

        address[] memory ofts2 = new address[](2);
        ofts2[0] = address(bOFT);
        ofts2[1] = address(aOFTAdapter);
        this.wireOApps(ofts2);

        // mint tokens
        aToken.mint(userA, initialBalance);
        bOFT.mint(userD, initialBalance);

        // setting fee receivers
        aOFTAdapter.setFeeReceiver(userFeeReceiver);
        bOFT.setFeeReceiver(userFeeReceiver);

        // labeling addresses
        vm.label(userA, "userA");
        vm.label(userB, "userB");
        vm.label(userD, "userD");
        vm.label(userFeeReceiver, "userFeeReceiver");
        vm.label(address(aToken), "aToken");
    }

    function test_constructor() public {
        assertEq(aOFTAdapter.owner(), address(this));
        assertEq(bOFT.owner(), address(this));

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        assertEq(aOFTAdapter.token(), address(aToken));
        assertEq(bOFT.token(), address(bOFT));
    }

    function test_setters() public {
        address addr1 = vm.addr(50000);
        address addr2 = vm.addr(50001);
        aOFTAdapter.setFeeReceiver(addr1);
        bOFT.setFeeReceiver(addr2);
        assertEq(aOFTAdapter.s_feeReceiver(), addr1);
        assertEq(bOFT.s_feeReceiver(), addr2);
    }

    function test_RevertIf_wrongPercentage() public {
        vm.expectRevert(abi.encodeWithSelector(BaseBeamBridge.BaseBeamBridge__InvalidFeePercentage.selector));
        bOFT.setFeePercentage(1e7);
        vm.expectRevert(abi.encodeWithSelector(BaseBeamBridge.BaseBeamBridge__InvalidFeePercentage.selector));
        aOFTAdapter.setFeePercentage(1e7);
    }

    function test_RevertIf_feeReceiverIsZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(BaseBeamBridge.BaseBeamBridge__ZeroAddress.selector));
        bOFT.setFeeReceiver(address(0));
    }

    function test_send_adapter_to_oft() public {
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSendIncludingFees);

        vm.prank(userA);
        aOFTAdapter.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userB), tokenToSendMinusFees);
        assertEq(aToken.balanceOf(userFeeReceiver), expectedFee);
    }

    function testFuzz_send_adapter_to_oft(uint256 randomFeePct) public {
        // testing fees from 0,1 % till 30%
        randomFeePct = bound(randomFeePct, 1e3, 1e5);
        aOFTAdapter.setFeePercentage(randomFeePct);
        uint256 newFeePercentage = aOFTAdapter.s_feePercentage();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * newFeePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSendIncludingFees);

        vm.prank(userA);
        aOFTAdapter.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userB), tokenToSendMinusFees);
        assertEq(aToken.balanceOf(userFeeReceiver), expectedFee);
    }

    function test_send_oft_to_adapter() public {
        oftAdapterToOft();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            aEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = bOFT.quoteSend(sendParam, false);

        assertEq(bOFT.balanceOf(userD), initialBalance);
        assertEq(aToken.balanceOf(userD), 0);

        vm.prank(userD);
        bOFT.approve(address(bOFT), tokensToSendIncludingFees);

        vm.prank(userD);
        bOFT.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(aEid, addressToBytes32(address(aOFTAdapter)));

        assertEq(bOFT.balanceOf(userD), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(userB)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userFeeReceiver), expectedFee);
    }

    function testFuzz_send_oft_to_adapter(uint256 randomFeePct) public {
        oftAdapterToOft();
        // testing fees from 0,1 % till 30%
        randomFeePct = bound(randomFeePct, 1e15, 3e17);
        bOFT.setFeePercentage(0);
        uint256 newFeePercentage = bOFT.s_feePercentage();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * newFeePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            aEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = bOFT.quoteSend(sendParam, false);

        assertEq(bOFT.balanceOf(userD), initialBalance);
        assertEq(aToken.balanceOf(userD), 0);

        vm.prank(userD);
        bOFT.approve(address(bOFT), tokensToSendIncludingFees);

        vm.prank(userD);
        bOFT.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(aEid, addressToBytes32(address(aOFTAdapter)));

        assertEq(bOFT.balanceOf(userD), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(userB)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userFeeReceiver), expectedFee);
    }

    function test_RevertIf_oft_SlippageExceeded() public {
        oftAdapterToOft();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        // that should cause the slippage control to activate
        uint256 minAmountLD = tokensToSendIncludingFees + 1;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            aEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            minAmountLD,
            options,
            "",
            ""
        );
        vm.expectRevert(abi.encodeWithSelector(IOFT.SlippageExceeded.selector, tokenToSendMinusFees, minAmountLD));
        MessagingFee memory fee = bOFT.quoteSend(sendParam, false);
    }

    function test_RevertIf_oftAdapter_SlippageExceeded() public {
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;
        // that should cause the slippage control to activate
        uint256 minAmountLD = tokensToSendIncludingFees + 1;
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            minAmountLD,
            options,
            "",
            ""
        );

        vm.expectRevert(abi.encodeWithSelector(IOFT.SlippageExceeded.selector, tokenToSendMinusFees, minAmountLD));
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);
    }

    function test_send_oft_to_adapter_no_fees() public {
        bOFT.setFeePercentage(0);
        uint256 newFeePercentage = bOFT.s_feePercentage();
        oftAdapterToOft();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * newFeePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            aEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = bOFT.quoteSend(sendParam, false);

        assertEq(bOFT.balanceOf(userD), initialBalance);
        assertEq(aToken.balanceOf(userD), 0);

        vm.prank(userD);
        bOFT.approve(address(bOFT), tokensToSendIncludingFees);

        vm.prank(userD);
        bOFT.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(aEid, addressToBytes32(address(aOFTAdapter)));

        assertEq(bOFT.balanceOf(userD), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(userB)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userFeeReceiver), expectedFee);
    }

    function test_send_adapter_to_oft_no_fees() public {
        aOFTAdapter.setFeePercentage(0);
        uint256 newFeePercentage = aOFTAdapter.s_feePercentage();
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * newFeePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSendIncludingFees);

        vm.prank(userA);
        aOFTAdapter.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(userB), tokenToSendMinusFees);
        assertEq(aToken.balanceOf(userFeeReceiver), expectedFee);
    }

    function test_send_oft_adapter_compose_msg() public {
        uint256 tokensToSendIncludingFees = 1 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        OFTComposerMock composer = new OFTComposerMock();

        bytes memory options = OptionsBuilder
            .newOptions()
            .addExecutorLzReceiveOption(200000, 0)
            .addExecutorLzComposeOption(0, 500000, 0);
        bytes memory composeMsg = hex"1234";
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(address(composer)),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            composeMsg,
            ""
        );
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSendIncludingFees);

        vm.prank(userA);
        (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) = aOFTAdapter.send{ value: fee.nativeFee }(
            sendParam,
            fee,
            payable(address(this))
        );
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        // lzCompose params
        uint32 dstEid_ = bEid;
        address from_ = address(bOFT);
        bytes memory options_ = options;
        bytes32 guid_ = msgReceipt.guid;
        address to_ = address(composer);
        bytes memory composerMsg_ = OFTComposeMsgCodec.encode(
            msgReceipt.nonce,
            aEid,
            oftReceipt.amountReceivedLD,
            abi.encodePacked(addressToBytes32(userA), composeMsg)
        );
        this.lzCompose(dstEid_, from_, options_, guid_, to_, composerMsg_);

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSendIncludingFees);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokenToSendMinusFees);
        assertEq(bOFT.balanceOf(address(composer)), tokenToSendMinusFees);
        assertEq(aToken.balanceOf(userFeeReceiver), expectedFee);

        assertEq(composer.from(), from_);
        assertEq(composer.guid(), guid_);
        assertEq(composer.message(), composerMsg_);
        assertEq(composer.executor(), address(this));
        assertEq(composer.extraData(), composerMsg_); // default to setting the extraData to the message as well to test
    }

    function test_permit() public {
        bOFT.mint(userA, initialBalance);
        uint256 amountToPermit = 1 ether;
        uint256 deadline = block.timestamp + 1 days;

        // Generate a signature for permit
        vm.prank(userA);
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(userA, userB, amountToPermit, deadline, 0); // Assuming nonce starts at 0

        // Before permit
        assertEq(aToken.allowance(userA, userB), 0);

        // Call permit
        vm.prank(userA);
        bOFT.permit(userA, userB, amountToPermit, deadline, v, r, s);

        // After permit, check allowance
        assertEq(bOFT.allowance(userA, userB), amountToPermit);

        // Transfer tokens using the permit method
        uint256 balanceBefore = bOFT.balanceOf(userB);
        vm.prank(userB);
        require(bOFT.transferFrom(userA, userB, amountToPermit), "Transfer not successful");

        // Check that the tokens have been transferred
        assertEq(bOFT.balanceOf(userB), balanceBefore + amountToPermit);
        assertEq(bOFT.nonces(userA), 1); // Check nonce increase
    }

    /// helper function
    function _signPermit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint256 nonce
    ) internal view returns (uint8, bytes32, bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonce,
                deadline
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", bOFT.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userAPk, digest);
        return (v, r, s);
    }

    /// @notice send tokens from the adapter to the OFT contract
    function oftAdapterToOft() public {
        uint256 tokensToSendIncludingFees = 2 ether;
        uint256 expectedFee = (tokensToSendIncludingFees * feePercentage) / PRECISION;
        uint256 tokenToSendMinusFees = tokensToSendIncludingFees - expectedFee;

        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam = SendParam(
            bEid,
            addressToBytes32(userB),
            tokensToSendIncludingFees,
            tokenToSendMinusFees,
            options,
            "",
            ""
        );
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSendIncludingFees);

        vm.prank(userA);
        aOFTAdapter.send{ value: fee.nativeFee }(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));
    }
}
