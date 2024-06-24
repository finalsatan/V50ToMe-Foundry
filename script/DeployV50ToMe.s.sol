// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {V50ToMe} from "../src/V50ToMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployV50ToMe is Script {
    function run() external returns (V50ToMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        V50ToMe v50ToMe = new V50ToMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return v50ToMe;
    }
}
