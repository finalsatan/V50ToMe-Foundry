// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {V50ToMe} from "../../src/V50ToMe.sol";
import {DeployV50ToMe} from "../../script/DeployV50ToMe.s.sol";
import {V50V50ToMe, WithdrawV50ToMe} from "../../script/Interaction.s.sol";

contract V50ToMeTestIntegration is Test {
    V50ToMe v50ToMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployV50ToMe deployV50ToMe = new DeployV50ToMe();
        v50ToMe = deployV50ToMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanV50Interactions() public {
        V50V50ToMe v50V50ToMe = new V50V50ToMe();
        v50V50ToMe.v50V50ToMe(address(v50ToMe));

        WithdrawV50ToMe withdrawV50ToMe = new WithdrawV50ToMe();
        withdrawV50ToMe.withdrawV50ToMe(address(v50ToMe));

        assertEq(address(v50ToMe).balance, 0);
    }
}
