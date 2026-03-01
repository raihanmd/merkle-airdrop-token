// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";

contract MerkleAirdropTest is Test {
  MerkleAirdrop airdrop;
  Token token;

  function setUp() public {
    token = new Token();

    // airdrop = new MerkleAirdrop(address(token));
  }
}
