const catchRevert = require("./utils/exceptions.js").catchRevert;
const { BN, constants, expectEvent, shouldFail } = require('../../node_modules/@openzeppelin/test-helpers');

const BettingPool = artifacts.require("BettingPool");
const teamNames = ["TEN", "KC", "BUF", "CIN", "LV", "NE", "PIT", "GB", "TB", "DAL", "LAR", "ARZ", "SF", "PHI"];
const betValue = 5000000000000000;

contract("BettingPool", (accounts) => {
    let [alice, bob, cam, dan] = accounts;
    let contractInstance;

    beforeEach(async () => {
        contractInstance = await BettingPool.new();
        await contractInstance.setUpBettingEvent(teamNames, betValue);
    });
    
    it("should be correctly set up", async () => {
        const acceptedTeams = await contractInstance.getAcceptedTeams();
        assert.deepEqual(acceptedTeams, teamNames);
        const betVal = await contractInstance.getBetValue();
        assert.equal(betVal, betValue);
        assert.equal(await contractInstance.isContractInUse(), true);
    })

    it("should be able to place a bet", async () => {
        const team = teamNames[4];
        const result = await contractInstance.placeBet(team, {from: alice, value: betValue});
        assert.equal(result.receipt.status, true);
        expectEvent.inLogs(result.logs, "BetPlaced", {
            player: alice,
            team: team,
            amount: new BN(BigInt(betValue))
        })
        const bets = await contractInstance.getAllBets();
        assert.equal(bets[0].team, teamNames[4]);
        assert.equal(bets[0].player, alice);
        assert.equal(bets[0].amount, betValue);

    })

    it("should store all the money in contract", async () => {
        await contractInstance.placeBet(teamNames[1], {from: alice, value: betValue});
        await contractInstance.placeBet(teamNames[2], {from: bob, value: betValue});
        await contractInstance.placeBet(teamNames[3], {from: cam, value: betValue});
        await contractInstance.placeBet(teamNames[4], {from: dan, value: betValue});
        const totalPot = await contractInstance.getTotalPot();
        assert.equal(totalPot, betValue*4);
    })

    it("should detect invalid team when placing a bet", async () => {
        await catchRevert(contractInstance.placeBet("INVALID", {from: alice, value: betValue}));
    })

    it("should not allow two bets from same player", async () => {
        const result = await contractInstance.placeBet(teamNames[1], {from: alice, value: betValue});
        assert.equal(result.receipt.status, true);
        await catchRevert(contractInstance.placeBet(teamNames[2], {from: alice, value: betValue}));
    })

    it("should not work unless exactly 0.005 eth is sent", async () => {
        await catchRevert(contractInstance.placeBet(teamNames[1], {from: alice, value: 6000000000000000}));
        await catchRevert(contractInstance.placeBet(teamNames[1], {from: bob, value: 4000000000000000}));
    })
})