// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop is EIP712 {
  using SafeERC20 for IERC20;

  error MerkleAirdrop__InvalidProof();
  error MerkleAirdrop__InvalidSignature();
  error MerkleAirdrop__AlreadyClaimed();

  event Claimed(address indexed account, uint256 amount);

  IERC20 private immutable i_token;
  bytes32 private immutable i_merkleRoot;

  mapping(address => bool) private s_claimed;

  bytes32 private constant CLAIM_TYPEHASH = keccak256("Claim(address account,uint256 amount)");

  struct Claim {
    address account;
    uint256 amount;
  }

  constructor(address token, bytes32 merkleRoot) EIP712("MerkleAirdrop", "1") {
    i_token = IERC20(token);
    i_merkleRoot = merkleRoot;
  }

  function claim(address account, uint256 amount, bytes32[] calldata merkleProof, uint8 v, bytes32 r, bytes32 s)
    external
  {
    if (s_claimed[account]) {
      revert MerkleAirdrop__AlreadyClaimed();
    }

    if (!_verifySignature(account, getMessageHash(account, amount), v, r, s)) {
      revert MerkleAirdrop__InvalidSignature();
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

  function claim(address account, uint256 amount, bytes32[] calldata merkleProof, bytes memory signature)
    external
  {
    if (s_claimed[account]) {
      revert MerkleAirdrop__AlreadyClaimed();
    }

    if (!_verifySignature(account, getMessageHash(account, amount), signature)) {
      revert MerkleAirdrop__InvalidSignature();
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

  function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(CLAIM_TYPEHASH, Claim({account: account, amount: amount}))));
  }

  // ====================
  // Internal functions
  // ====================
  function _verifySignature(address account, bytes32 digest, uint8 v, bytes32 r, bytes32 s)
    internal
    pure
    returns (bool)
  {
    (address signer,,) = ECDSA.tryRecover(digest, v, r, s);
    return signer == account;
  }

  function _verifySignature(address account, bytes32 digest, bytes memory signature) internal pure returns (bool) {
    (address signer,,) = ECDSA.tryRecover(digest, signature);
    return signer == account;
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
