const catchRevert = require("./utils/exceptions.js").catchRevert;
const { BN, constants, expectEvent, shouldFail } = require('../../node_modules/@openzeppelin/test-helpers');

const Payout = artifacts.require("Payout");
const teamNames = ["TEN", "KC", "BUF", "CIN", "LV", "NE", "PIT", "GB", "TB", "DAL", "LAR", "ARZ", "SF", "PHI"];
const betValueInEth = '0.005';
const eventFilter = { fromBlock: 0, toBlock: 'latest'};

contract("Payout", (accounts) => {
    let [alice, bob, cam, dan] = accounts;
    let contractInstance;

    beforeEach(async () => {
        contractInstance = await Payout.new();
        await contractInstance.setUpBettingEvent(teamNames, web3.utils.toWei(betValueInEth, 'ether'));
        await contractInstance.placeBet(teamNames[1], {from: alice, value: web3.utils.toWei(betValueInEth, 'ether')});
        await contractInstance.placeBet(teamNames[1], {from: bob, value: web3.utils.toWei(betValueInEth, 'ether')});
        await contractInstance.placeBet(teamNames[7], {from: cam, value: web3.utils.toWei(betValueInEth, 'ether')});
        await contractInstance.placeBet(teamNames[12], {from: dan, value: web3.utils.toWei(betValueInEth, 'ether')});
    });

    it("should be correctly set up", async () => {
        const totalPot = await contractInstance.getTotalPot();
        assert.equal(totalPot, (web3.utils.toWei(betValueInEth, 'ether')*4));
        const allBets = await contractInstance.getAllBets();
        assert.equal(allBets.length, 4);
    })

    it("should pay Alice and Bob who split the pot", async () => {
        const expectedPayout = BigInt(web3.utils.toWei(betValueInEth, 'ether') * 2);
        const result = await contractInstance.payPlayers(teamNames[1]);
        assert.equal(result.receipt.status, true);
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: alice,
            amount: new BN(expectedPayout)
          });
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: bob,
            amount: new BN(expectedPayout)
          });
    })

    it("should pay cam all pot money", async () => {
      const expectedPayout = BigInt(web3.utils.toWei(betValueInEth, 'ether') * 4);
      const result = await contractInstance.payPlayers(teamNames[7]);
      assert.equal(result.receipt.status, true);
      expectEvent.inLogs(result.logs, "PlayerGotPayed", {
          player: cam,
          amount: new BN(expectedPayout)
        });
  })

    it("should pay everybody back their buy in", async () => {
        const expectedPayout = BigInt(web3.utils.toWei(betValueInEth, 'ether'));
        // nobody bet on winner
        const result = await contractInstance.payPlayers(teamNames[4]);
        assert.equal(result.receipt.status, true);
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: alice,
            amount: new BN(expectedPayout)
          });
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: bob,
            amount: new BN(expectedPayout)
          });
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: cam,
            amount: new BN(expectedPayout)
          });
        expectEvent.inLogs(result.logs, "PlayerGotPayed", {
            player: dan,
            amount: new BN(expectedPayout)
          });
    })

    it("should reset contract after payout", async () => {
        const result = await contractInstance.payPlayers(teamNames[1]);
        assert.equal(result.receipt.status, true);
        assert.equal(await contractInstance.isContractInUse(), false);
        const acceptedTeams = await contractInstance.getAcceptedTeams();
        assert.deepEqual(acceptedTeams, []);
        const allBets = await contractInstance.getAllBets();
        assert.deepEqual(allBets, []);
        const betVal = await contractInstance.getBetValue();
        assert.equal(betVal, 0);
    })

    it("should allow player to play in multiple rounds", async () => {
        const result = await contractInstance.payPlayers(teamNames[1]);
        assert.equal(result.receipt.status, true);
        assert.equal(await contractInstance.isContractInUse(), false);
        await contractInstance.setUpBettingEvent(teamNames, web3.utils.toWei(betValueInEth, 'ether'));
        assert.equal(await contractInstance.isContractInUse(), true);
        const result1 = await contractInstance.placeBet(teamNames[1], {from: alice, value: web3.utils.toWei(betValueInEth, 'ether')});
        assert.equal(result1.receipt.status, true);
    })
    
});