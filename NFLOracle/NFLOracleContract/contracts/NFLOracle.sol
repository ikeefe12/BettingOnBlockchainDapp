//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./Ownable/Ownable.sol";
import "./NFLCallerContractInterface.sol";

contract NFLOracle is Ownable {
  uint private randNonce = 0;
  uint private modulus = 1000;

  mapping(uint256=>bool) pendingRequests;

  event GetNFLGameWinnerEvent(address callerAddress, string gameId, uint id);
  event SetNFLGameWinnerEvent(string gameId, string winner, address callerAddress);

  function getNFLGameWinner(string memory _gameId) public returns (uint256) {
    randNonce++;
    uint id = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce, _gameId))) % modulus;
    pendingRequests[id] = true;
    emit GetNFLGameWinnerEvent(msg.sender, _gameId, id);
    return id;
  }

  function setNFLGameWinner(string memory _winner, string memory _gameId, address _callerAddress, uint256 _id) public onlyOwner {
    require(pendingRequests[_id], "This request is not in my pending list.");
    delete pendingRequests[_id];
    NFLCallerContractInterface callerContractInstance;
    callerContractInstance = NFLCallerContractInterface(_callerAddress);
    callerContractInstance.callback(_winner, _gameId, _id);
    emit SetNFLGameWinnerEvent(_winner, _gameId, _callerAddress);
  }
}