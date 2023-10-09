// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "./EmailWalletCoreTestHelper.sol";

contract TransferTest is EmailWalletCoreTestHelper {
    function setUp() public override {
        super.setUp();
        _registerRelayer();
        _registerAndInitializeAccount();
    }

    function testSendTokenToEOA() public {
        address recipient = vm.addr(5);
        string memory subject = string.concat("Send 100 DAI to ", Strings.toHexString(uint160(recipient), 20));

        // Mint 150 DAI to sender wallet (will send 100 DAI to recipient)
        daiToken.freeMint(walletAddr, 150 ether);

        // Create EmailOp
        EmailOp memory emailOp = _getBaseEmailOp();
        emailOp.command = Commands.SEND;
        emailOp.walletParams.tokenName = "DAI";
        emailOp.walletParams.amount = 100 ether;
        emailOp.recipientETHAddr = recipient;
        emailOp.maskedSubject = subject;

        vm.startPrank(relayer);
        (bool success, ) = core.handleEmailOp(emailOp);
        vm.stopPrank();

        assertEq(success, true, "handleEmailOp failed");
        assertEq(daiToken.balanceOf(recipient), 100 ether, "recipient did not receive 100 DAI");
        assertEq(daiToken.balanceOf(walletAddr), 50 ether, "sender did not have 50 DAI left");
    }

    function testSendTokenToEOAWithDecimals() public {
        address recipient = vm.addr(5);
        string memory subject = string.concat("Send 10.52 DAI to ", Strings.toHexString(uint160(recipient), 20));

        daiToken.freeMint(walletAddr, 20 ether);

        EmailOp memory emailOp = _getBaseEmailOp();
        emailOp.command = Commands.SEND;
        emailOp.walletParams.tokenName = "DAI";
        emailOp.walletParams.amount = 10.52 ether;
        emailOp.recipientETHAddr = recipient;
        emailOp.maskedSubject = subject;

        vm.startPrank(relayer);
        (bool success, ) = core.handleEmailOp(emailOp);
        vm.stopPrank();

        assertEq(success, true, "handleEmailOp failed");
        assertEq(daiToken.balanceOf(recipient), 10.52 ether, "recipient did not receive 10.52 DAI");
        assertEq(daiToken.balanceOf(walletAddr), 9.48 ether, "sender did not have 9.48 DAI left");
    }
}