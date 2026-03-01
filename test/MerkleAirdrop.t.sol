// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {Token} from "../src/Token.sol";

import {MerkleAirdropDeploy} from "../script/MerkleAirdropDeploy.s.sol";

contract MerkleAirdropTest is Test {
  MerkleAirdrop airdrop;
  Token token;
  bytes32 merkleRoot = 0x4797c7a38f6e3c2da3b6e833159b719dcd2b6bd9cf0575e11e673a4d6a8a48cf;

  uint256 amount = 25e18; // 25 tokens with 18 decimals

  address account1 = address(0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D);
  address account2 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
  address account3 = address(0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd);
  address account4 = address(0x08Dc514b8bA9015a74972Da8bDa5027fD91943e1);

  bytes32 proof1One = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
  bytes32 proof1Two = 0x74aded9f47912765423c6564320da18a960d56a893263dde9696d12d8b3a7421;
  bytes32[] proof1 = [proof1One, proof1Two];

  function setUp() public {
    (airdrop, token) = new MerkleAirdropDeploy().run();

    token.mint(address(airdrop), amount * 4);
  }

  function test_claim() public {
    uint256 initialBalance = token.balanceOf(account1);

    airdrop.claim(account1, amount, proof1);

    assertEq(token.balanceOf(account1), initialBalance + amount);
  }
}
