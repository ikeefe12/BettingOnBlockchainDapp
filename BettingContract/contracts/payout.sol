//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

import "./bettingpool.sol";

contract Payout is BettingPool {

    event PlayerGotPayed(address indexed player, uint amount);
    event WinningTeamEstablished(uint round, string team);

    // this function will pay players and return contract to starting point
    function payPlayers(string memory winningTeam) external inUse {
        require(checkTeamValid(winningTeam), "The team is not valid");
        require(contractInUse, "contract is not in use");

        // winning team is valid
        contractInUse = false; 
        emit WinningTeamEstablished(bettingRound, winningTeam);

        bytes32 winningTeamHash = keccak256(abi.encodePacked(winningTeam));
        address payable[] memory winners = new address payable[](bets.length);
        // get the winning players
        uint numberOfWinners = 0;
        for (uint i = 0; i < bets.length; i++) {
            address player = bets[i].player;
            // use this loop to eliminate the playerHasBet mapping
            delete playerHasBet[player];
            if(keccak256(abi.encodePacked(bets[i].team)) == winningTeamHash) {
                winners[numberOfWinners] = payable(player);
                numberOfWinners++;
            }
        }
        // pay players accordingly
        if (numberOfWinners == 0) { // everyone gets their money back
            for (uint i = 0; i < bets.length; i++) {
                uint payout = bets[i].amount;
                address payable player = payable(bets[i].player);
                player.transfer(payout);
                emit PlayerGotPayed(player, payout);
            }
        } else { // winners split the pot
            uint totalPot = address(this).balance;
            uint payout = totalPot / numberOfWinners;
            for (uint i = 0; i < numberOfWinners; i++) {
                winners[i].transfer(payout);
                emit PlayerGotPayed(winners[i], payout);
            }
        }
        // game is over, reset for next round
        resetContract();
    }
        
    
    function resetContract() private {
        betValue = 0;
        delete bets;
        delete acceptedTeams;
    }
}