// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
  using SafeERC20 for IERC20;

  error MerkleAirdrop__InvalidProof();
  error MerkleAirdrop__AlreadyClaimed();

  event Claimed(address indexed account, uint256 amount);

  IERC20 private immutable i_token;
  bytes32 private immutable i_merkleRoot;

  mapping(address => bool) private s_claimed;

  constructor(address token, bytes32 merkleRoot) {
    i_token = IERC20(token);
    i_merkleRoot = merkleRoot;
  }

  function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
    if (s_claimed[account]) {
      revert MerkleAirdrop__AlreadyClaimed();
    }

    // Leaf node = account + amount
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));

    if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
      revert MerkleAirdrop__InvalidProof();
    }

    s_claimed[account] = true;

    emit Claimed(account, amount);
    i_token.safeTransfer(account, amount);
  }

  // ====================
  // View functions
  // ====================
  function getToken() external view returns (IERC20) {
    return i_token;
  }

  function getMerkleRoot() external view returns (bytes32) {
    return i_merkleRoot;
  }

  function isClaimed(address account) external view returns (bool) {
    return s_claimed[account];
  }
}
