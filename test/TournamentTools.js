const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TournamentTools", function () {
  let TournamentTools;
  let tournamentTools;

  beforeEach(async function () {
    TournamentTools = await ethers.getContractFactory("TournamentTools");
    tournamentTools = await TournamentTools.deploy();
    await tournamentTools.deployed();
  });

  it("Should return true if number is in array", async function () {
    expect(await tournamentTools.isInIntArray([1, 2, 3], 2)).to.equal(true);
  });

  it("Should return false if number is not in array", async function () {
    expect(await tournamentTools.isInIntArray([1, 2, 3], 4)).to.equal(false);
  });

  it("Should return true if address is in array", async function () {
    let addr1 = ethers.constants.AddressZero;
    let addr2 = ethers.constants.AddressZero;
    expect(await tournamentTools.isInAddressArray([addr1], addr2)).to.equal(true);
  });

  it("Should return false if address is not in array", async function () {
    let addr1 = ethers.constants.AddressZero;
    let addr2 = ethers.Wallet.createRandom().address;
    expect(await tournamentTools.isInAddressArray([addr1], addr2)).to.equal(false);
  });

  it("Should correctly update ratings", async function () {
    let winnerRating = 1200;
    let loserRating = 1000;
    let [newWinnerRating, newLoserRating] = await tournamentTools.updateRating(winnerRating, loserRating);
    expect(newWinnerRating).to.be.gt(winnerRating);
    expect(newLoserRating).to.be.lt(loserRating);
  });
});