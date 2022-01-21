//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./NFLOracleInterface.sol";
import "./Ownable/Ownable.sol";

contract NFLCallerContract is Ownable {
    struct game {
        string id;
        string winner;
    }

    game[] private winners;

    event newNFLOracleAddressEvent(address oracleAddress);
    event ReceivedNewNFLRequestIdEvent(uint256 id, string gameId);
    event NFLRequestIdSatisfiedEvent(uint256 id, string winner);

    mapping(uint256=>bool) myRequests;

    NFLOracleInterface private oracleInstance;
    address private oracleAddress;

    function setOracleInstanceAddress (address _oracleInstanceAddress) public onlyOwner {
      oracleAddress = _oracleInstanceAddress;
      oracleInstance = NFLOracleInterface(oracleAddress);
      emit newNFLOracleAddressEvent(oracleAddress);
    }

    function getNFLGameWinner(string memory _gameId) public {
        uint256 id = oracleInstance.getNFLGameWinner(_gameId);
        myRequests[id] = true;
        emit ReceivedNewNFLRequestIdEvent(id, _gameId);
    }

    function callback(string memory _winner, string memory _gameId, uint256 _id) public onlyOracle {
        require(myRequests[_id] == true);
        winners.push(game(_gameId, _winner));
        delete(myRequests[_id]);
        emit NFLRequestIdSatisfiedEvent(_id, _winner);
    }

    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "You are not authorized to call this function.");
        _;
    }
}