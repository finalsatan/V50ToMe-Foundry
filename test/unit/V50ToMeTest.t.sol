// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {V50ToMe} from "../../src/V50ToMe.sol";
import {DeployV50ToMe} from "../../script/DeployV50ToMe.s.sol";

contract V50ToMeTest is Test {
    V50ToMe v50ToMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployV50ToMe deployV50ToMe = new DeployV50ToMe();
        v50ToMe = deployV50ToMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumCnyIsFifty() public view {
        assertEq(v50ToMe.MINIMUM_CNY(), 50e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(v50ToMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = v50ToMe.getVersion();
        assertEq(version, 4);
    }

    function testV50ToMeFailsWithoutEnoughETH() public {
        vm.expectRevert();
        v50ToMe.V50();
    }

    function testV50ToMeUpdatesV50DataStructure() public {
        vm.prank(USER);
        v50ToMe.V50{value: SEND_VALUE}();
        uint256 amountV50 = v50ToMe.getAddressToAmountV50(USER);
        assertEq(amountV50, SEND_VALUE);
    }

    function testAddsV50erToArrayOfV50ers() public v50ed {
        address v50er = v50ToMe.getV50er(0);
        assertEq(v50er, USER);
    }

    modifier v50ed() {
        vm.prank(USER);
        v50ToMe.V50{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public v50ed {
        vm.expectRevert();
        vm.prank(USER);
        v50ToMe.withdraw();
    }

    function testWithdrawWithASingleV50er() public v50ed {
        //arrange
        uint256 startingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 startingV50ToMeBalance = address(v50ToMe).balance;

        //act
        vm.prank(v50ToMe.getOwner());
        v50ToMe.withdraw();

        //assert
        uint256 endingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 endingV50ToMeBalance = address(v50ToMe).balance;
        assertEq(startingV50ToMeBalance, SEND_VALUE);
        assertEq(endingV50ToMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + SEND_VALUE);
    }

    function testWithdrawWithMultipleV50ers() public v50ed {
        //arrange
        uint160 numberOfV50ers = 10;
        uint160 startingV50erIndex = 1;
        for (uint160 i = startingV50erIndex; i < numberOfV50ers; i++) {
            hoax(address(i), SEND_VALUE);
            v50ToMe.V50{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 startingV50ToMeBalance = address(v50ToMe).balance;

        //act
        vm.startPrank(v50ToMe.getOwner());
        v50ToMe.withdraw();
        vm.stopPrank();

        //assert
        uint256 endingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 endingV50ToMeBalance = address(v50ToMe).balance;
        assertEq(startingV50ToMeBalance, 10 * SEND_VALUE);
        assertEq(endingV50ToMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + 10 * SEND_VALUE);
        assertEq(
            startingOwnerBalance + startingV50ToMeBalance,
            v50ToMe.getOwner().balance
        );
    }

    function testWithdrawWithMultipleV50ersCheaper() public v50ed {
        //arrange
        uint160 numberOfV50ers = 10;
        uint160 startingV50erIndex = 1;
        for (uint160 i = startingV50erIndex; i < numberOfV50ers; i++) {
            hoax(address(i), SEND_VALUE);
            v50ToMe.V50{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 startingV50ToMeBalance = address(v50ToMe).balance;

        //act
        vm.startPrank(v50ToMe.getOwner());
        v50ToMe.cheaperWithdraw();
        vm.stopPrank();

        //assert
        uint256 endingOwnerBalance = v50ToMe.getOwner().balance;
        uint256 endingV50ToMeBalance = address(v50ToMe).balance;
        assertEq(startingV50ToMeBalance, 10 * SEND_VALUE);
        assertEq(endingV50ToMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + 10 * SEND_VALUE);
        assertEq(
            startingOwnerBalance + startingV50ToMeBalance,
            v50ToMe.getOwner().balance
        );
    }
}
// 测试代码中可以使用 console.log() 来输出日志，执行测试的时候需要使用 forge test -vvvvv
