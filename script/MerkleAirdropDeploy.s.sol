// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";
import {TokenDeploy} from "./TokenDeploy.s.sol";

import {Merkle} from "murky/src/Merkle.sol";
import {Script} from "forge-std/Script.sol";

contract MerkleAirdropDeploy is Script {
  bytes32 merkleRoot = 0x4797c7a38f6e3c2da3b6e833159b719dcd2b6bd9cf0575e11e673a4d6a8a48cf;
  uint256 amountToAirdrop = 4 * 25e18; // 25 tokens with 18 decimals

  function run() external returns (MerkleAirdrop, Token) {
    return deploy(msg.sender);
  }

  function deploy(address owner) public returns (MerkleAirdrop airdrop, Token token) {
    token = new TokenDeploy().deploy(owner);

    vm.startBroadcast(owner);

    airdrop = new MerkleAirdrop(address(token), merkleRoot);

    token.mint(address(airdrop), amountToAirdrop);

    token.transferOwnership(owner);

    vm.stopBroadcast();
  }
}
