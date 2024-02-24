const { ethers, upgrades } = require("hardhat");

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const repoName = "MyRepo";
  const totalRepoKeys = 100;
  const description = "MyRepo Description";
  const code = ["code1", "code2"];
  const filenames = ["file1", "file2"];
  const URI = "https://mytoken.com/";
  const branch = "MAIN";

  await deploy("GitXDC", {
    from: deployer,
    args: [repoName, totalRepoKeys, description, code, filenames, URI, branch],
    log: true,
  });
};

module.exports.tags = ["GitXDC"];