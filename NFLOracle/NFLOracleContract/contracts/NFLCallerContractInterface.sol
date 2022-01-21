//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface NFLCallerContractInterface {
  function callback(string memory, string memory, uint256) external;
}
