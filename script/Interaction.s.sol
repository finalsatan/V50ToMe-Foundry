// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {V50ToMe} from "../src/V50ToMe.sol";

// fund

// withdraw

contract V50V50ToMe is Script {
    uint256 SEND_VALUE = 0.01 ether;

    function v50V50ToMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        V50ToMe(payable(mostRecentlyDeployed)).V50{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("V50 V50ToMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "V50ToMe",
            block.chainid
        );
        v50V50ToMe(mostRecentlyDeployed);
    }
}

contract WithdrawV50ToMe is Script {
    function withdrawV50ToMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        V50ToMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "V50ToMe",
            block.chainid
        );
        vm.startBroadcast();
        withdrawV50ToMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
