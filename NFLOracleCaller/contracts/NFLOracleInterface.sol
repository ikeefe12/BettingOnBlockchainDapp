//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface NFLOracleInterface {
  function getNFLGameWinner(string memory) external returns (uint256);
}
