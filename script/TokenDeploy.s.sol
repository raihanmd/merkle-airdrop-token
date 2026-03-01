// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Token} from "../src/Token.sol";

import {Script} from "forge-std/Script.sol";

contract TokenDeploy is Script {
  function run() external returns (Token) {
    return deploy(msg.sender);
  }

  function deploy(address owner) public returns (Token token) {
    vm.startBroadcast(owner);

    token = new Token();
    token.transferOwnership(owner);

    vm.stopBroadcast();
  }
}
