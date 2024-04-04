const { expect } = require("chai");

describe("Tournament contract", function() {
  let Tournament;
  let tournament;

  beforeEach(async function() {
    Tournament = await ethers.getContractFactory("Tournament");
    tournament = await Tournament.deploy();
    await tournament.deployed();
  });

  describe("Deployment", function() {
    it("Should set the right owner", async function() {
      expect(await tournament.owner()).to.equal(owner.address);
    });
  });

  describe("Transactions", function() {
    it("Should create a tournament", async function() {
      await tournament.createTournament("Test Tournament", 8);
      expect(await tournament.tournamentCounter()).to.equal(1);
    });

  });
});
