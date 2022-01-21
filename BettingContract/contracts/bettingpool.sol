//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./Ownable/Ownable.sol";

contract BettingPool is Ownable {
    event BetPlaced(address indexed player, string team, uint amount);

    // this will be used to store the number of different betting games the contract has executed
    uint bettingRound; 

    bool contractInUse; 
    uint betValue;

    struct Bet {
        address player;
        string team;        // using official abbreviations
        uint amount;        // this amount will contain 8 decimals
    }

    Bet[] bets;
    string[] acceptedTeams;

    mapping (address => bool) playerHasBet;

    modifier notInUse() {
        require(contractInUse == false, "Contract is in use");
        _;
    }

    modifier inUse() {
        require(contractInUse, "Contract is not in use");
        _;
    }

    function checkTeamValid(string memory team) internal view returns (bool) {
        for (uint i = 0; i < acceptedTeams.length; i++) {
            if (keccak256(abi.encodePacked(acceptedTeams[i])) == keccak256(abi.encodePacked(team))) {
                return true;
            }
        }
        return false;
    }

    constructor() {
        bettingRound = 0;
        contractInUse = false;
    }

    function setUpBettingEvent(string[] memory teams, uint valueOfBets) external onlyOwner notInUse {
        require(teams.length > 1, "Can't have a betting game without at least two teams.");
        bettingRound++;
        contractInUse = true;
        betValue = valueOfBets;
        addTeams(teams);
    }

    function addTeams(string[] memory teams) private {
        for (uint i = 0; i < teams.length; i++) {
            acceptedTeams.push(teams[i]);
        }
    }

    function placeBet(string memory team) external payable inUse {
        address player = msg.sender;
        uint amount = msg.value;
        // Check that bet is valid
        require(amount == betValue, "Incorrect funds.");
        require(checkTeamValid(team), "Team is invalid.");
        require(playerHasBet[player]==false, "Player has already bet");
        // Place bet and emit event
        bets.push(Bet(player, team, amount));
        playerHasBet[player] = true;
        emit BetPlaced(player, team, amount);
    }

    // will tell if contract is in use
    function isContractInUse() external view returns(bool) {
         return contractInUse;
    }

    // get an array of all bets place, bets are in obect format
    function getAllBets() external view returns(Bet[] memory) {
         Bet[] memory result = new Bet[](bets.length);
         for (uint i = 0; i < bets.length; i++) {
             result[i] = bets[i];
         }
         return result;
    }

    // return the set bet value of the contract
    function getBetValue() external view returns(uint) {
         return betValue;
    }

    // total amount the contract holds in wei
    function getTotalPot() external view returns(uint) {
         return address(this).balance;
    }

    // get array of all accepted teams
    function getAcceptedTeams() external view returns(string[] memory) {
        string[] memory result = new string[](acceptedTeams.length);
        for (uint i = 0; i < acceptedTeams.length; i++) {
            result[i] = acceptedTeams[i];
        }
        return result;
    }

}
