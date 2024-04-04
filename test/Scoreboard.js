const { expect } = require("chai");

describe("Scoreboard contract", function() {
  let Scoreboard;
  let scoreboard;

  beforeEach(async function() {
    Scoreboard = await ethers.getContractFactory("Scoreboard");
    scoreboard = await Scoreboard.deploy();
    await scoreboard.deployed();
  });

  describe("Deployment", function() {
    it("Should set the right gameCounter", async function() {
      expect(await scoreboard.gameCounter()).to.equal(0);
    });

    it("Should set the right scoreboard", async function() {
      expect(await scoreboard.scoreboard()).to.equal("Default");
    });
  });
});