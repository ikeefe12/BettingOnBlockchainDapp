//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

interface NFLcallerContractInterface {
  function callback(string memory _winner, uint256 _id) external;
}
