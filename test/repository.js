const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GitXDC", function () {
  let GitXDC;
  let gitXDC;

  beforeEach(async function () {
    GitXDC = await ethers.getContractFactory("GitXDC");
    gitXDC = await GitXDC.deploy("MyRepo", 1, "MyDescription", ["code1", "code2"], ["file1.txt", "file2.txt"], "URI", "branch1");
    await gitXDC.deployed();
  });

  it("Should return the correct repo name", async function () {
    expect(await gitXDC.name()).to.equal("MyRepo");
  });

  it("Should increment version count after editRepo", async function () {
    await gitXDC.editRepo(["newCode"], ["newFile.txt"]);
    expect(await gitXDC.versionCount()).to.equal(2);
  });
});