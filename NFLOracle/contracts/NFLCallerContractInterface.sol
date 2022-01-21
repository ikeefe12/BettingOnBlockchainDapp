//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface NFLCallerContractInterface {
  function callback(string memory _winner, string memory _gameId, uint256 _id) external;
}
