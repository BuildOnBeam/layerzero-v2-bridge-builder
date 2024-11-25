// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Mock imports

import {OFTPermitMock} from "../mocks/OFTPermitMock.sol";
import {BeamOFTAdapter} from "../../contracts/ERC20/BeamOFTAdapter.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import {OFTComposerMock} from "../mocks/OFTComposerMock.sol";

// OApp imports
import {
    IOAppOptionsType3, EnforcedOptionParam
} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OAppOptionsType3.sol";
import {OptionsBuilder} from "@layerzerolabs/oapp-evm/contracts/oapp/libs/OptionsBuilder.sol";

// OFT imports
import {IOFT, SendParam, OFTReceipt} from "@layerzerolabs/oft-evm/contracts/interfaces/IOFT.sol";
import {MessagingFee, MessagingReceipt} from "@layerzerolabs/oft-evm/contracts/OFTCore.sol";
import {OFTMsgCodec} from "@layerzerolabs/oft-evm/contracts/libs/OFTMsgCodec.sol";
import {OFTComposeMsgCodec} from "@layerzerolabs/oft-evm/contracts/libs/OFTComposeMsgCodec.sol";

// OZ imports
import {IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

// Forge imports
import "forge-std/console.sol";

// DevTools imports
import {TestHelperOz5} from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

contract BeamOFTPermitTest is TestHelperOz5 {
    using OptionsBuilder for bytes;

    uint32 private aEid = 1;
    uint32 private bEid = 2;

    ERC20Mock private aToken;
    BeamOFTAdapter private aOFTAdapter;
    OFTPermitMock private bOFT;
    uint256 userAPk = 0x1;
    uint256 userBPk = 0x2;
    address private userA = vm.addr(userAPk);
    address private userB = vm.addr(userBPk);
    uint256 private initialBalance = 100 ether;

    function setUp() public virtual override {
        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);

        super.setUp();
        setUpEndpoints(2, LibraryType.UltraLightNode);

        aToken = ERC20Mock(_deployOApp(type(ERC20Mock).creationCode, abi.encode("Token", "TOKEN")));

        aOFTAdapter = BeamOFTAdapter(
            _deployOApp(
                type(BeamOFTAdapter).creationCode,
                abi.encode(address(aToken), address(endpoints[aEid]), address(this), 0)
            )
        );

        bOFT = OFTPermitMock(
            _deployOApp(
                type(OFTPermitMock).creationCode,
                abi.encode("Token", "TOKEN", address(endpoints[bEid]), address(this), 0)
            )
        );

        // config and wire the ofts
        address[] memory ofts = new address[](2);
        ofts[0] = address(aOFTAdapter);
        ofts[1] = address(bOFT);
        this.wireOApps(ofts);

        // mint tokens
        aToken.mint(userA, initialBalance);
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

    function test_send_oft_adapter() public {
        uint256 tokensToSend = 1 ether;
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);
        SendParam memory sendParam =
            SendParam(bEid, addressToBytes32(userB), tokensToSend, tokensToSend, options, "", "");
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSend);

        vm.prank(userA);
        aOFTAdapter.send{value: fee.nativeFee}(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSend);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokensToSend);
        assertEq(bOFT.balanceOf(userB), tokensToSend);
    }

    function test_send_oft_adapter_compose_msg() public {
        uint256 tokensToSend = 1 ether;

        OFTComposerMock composer = new OFTComposerMock();

        bytes memory options =
            OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0).addExecutorLzComposeOption(0, 500000, 0);
        bytes memory composeMsg = hex"1234";
        SendParam memory sendParam =
            SendParam(bEid, addressToBytes32(address(composer)), tokensToSend, tokensToSend, options, composeMsg, "");
        MessagingFee memory fee = aOFTAdapter.quoteSend(sendParam, false);

        assertEq(aToken.balanceOf(userA), initialBalance);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), 0);
        assertEq(bOFT.balanceOf(userB), 0);

        vm.prank(userA);
        aToken.approve(address(aOFTAdapter), tokensToSend);

        vm.prank(userA);
        (MessagingReceipt memory msgReceipt, OFTReceipt memory oftReceipt) =
            aOFTAdapter.send{value: fee.nativeFee}(sendParam, fee, payable(address(this)));
        verifyPackets(bEid, addressToBytes32(address(bOFT)));

        // lzCompose params
        uint32 dstEid_ = bEid;
        address from_ = address(bOFT);
        bytes memory options_ = options;
        bytes32 guid_ = msgReceipt.guid;
        address to_ = address(composer);
        bytes memory composerMsg_ = OFTComposeMsgCodec.encode(
            msgReceipt.nonce, aEid, oftReceipt.amountReceivedLD, abi.encodePacked(addressToBytes32(userA), composeMsg)
        );
        this.lzCompose(dstEid_, from_, options_, guid_, to_, composerMsg_);

        assertEq(aToken.balanceOf(userA), initialBalance - tokensToSend);
        assertEq(aToken.balanceOf(address(aOFTAdapter)), tokensToSend);
        assertEq(bOFT.balanceOf(address(composer)), tokensToSend);

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
    function _signPermit(address owner, address spender, uint256 value, uint256 deadline, uint256 nonce)
        internal
        view
        returns (uint8, bytes32, bytes32)
    {
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

    // TODO import the rest of oft tests?
}
