// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  // Compile our contract
  await hre.run("compile");

  // Get the contract to deploy
  const InventoryManager = await hre.ethers.getContractFactory("InventoryManager");

  // Start deployment, returning a promise that resolves to a contract object
  const keys = 10; // replace with the number of keys you want to initialize
  const adminAddress = "0x0000000000000000000000000000000000000000" // replace with the admin address
  const URI = ""; 
  const inventoryManager = await InventoryManager.deploy(keys, adminAddress, URI);

  console.log("Contract deployed to address:", inventoryManager.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });