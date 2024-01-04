// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {BasicLending} from "../src/BasicLending.sol";

contract DeployBasicLending is Script {
  function run() external returns(BasicLending) {
    vm.startBroadcast();
    BasicLending basicLending = new BasicLending();
    vm.stopBroadcast();
    return basicLending;
  }
}
