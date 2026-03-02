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

  address account1;
  uint256 account1PrivKey;

  address account2 = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // gas payer

  bytes32 proof1One = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
  bytes32 proof1Two = 0x74aded9f47912765423c6564320da18a960d56a893263dde9696d12d8b3a7421;
  bytes32[] proof1 = [proof1One, proof1Two];

  function setUp() public {
    (account1, account1PrivKey) = makeAddrAndKey("user");

    (airdrop, token) = new MerkleAirdropDeploy().run();

    token.mint(address(airdrop), amount * 4);
  }

  function test_claim_vrs() public {
    uint256 initialBalance = token.balanceOf(account1);

    bytes32 digest = airdrop.getMessageHash(account1, amount);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(account1PrivKey, digest);

    vm.prank(account2);
    airdrop.claim(account1, amount, proof1, v, r, s);

    assertEq(token.balanceOf(account1), initialBalance + amount);
  }

  function test_claim_signature() public {
    uint256 initialBalance = token.balanceOf(account1);

    bytes32 digest = airdrop.getMessageHash(account1, amount);

    (uint8 v, bytes32 r, bytes32 s) = vm.sign(account1PrivKey, digest);

    vm.prank(account2);
    airdrop.claim(account1, amount, proof1, bytes.concat(r, s, bytes1(v)));

    assertEq(token.balanceOf(account1), initialBalance + amount);
  }
}
