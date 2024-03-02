const hre = require("hardhat");

async function main() {
  const contractName = "InventoryManager"; 
  const [deployer] = await hre.ethers.getSigners();

  const artifact = await hre.artifacts.readArtifact(contractName);

  console.log("Bytecode of the contract:", artifact.bytecode);

  const adminURI =  "https://mywebsite.com/api/token/{tokenId}.json"
  const clientURI = ""
  const tokenURI = ""

  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Admin = await hre.ethers.getContractFactory("Admin");
  const admin = await Admin.deploy("TestTokenization", "Test", 4, 3, artifact, adminURI);

  await admin.deployed();

  console.log("Admin deployed to:", admin.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });