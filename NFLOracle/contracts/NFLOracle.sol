//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./Ownable/Ownable.sol";
import "./NFLCallerContractInterface.sol";

contract NFLOracle is Ownable {
  uint private randNonce = 0;
  uint private modulus = 1000;

  mapping(uint256=>bool) pendingRequests;

  event GetNFLGameWinnerEvent(address callerAddress, uint id);
  event SetNFLGameWinnerEvent(uint256 ethPrice, address callerAddress);

  // Start here
}