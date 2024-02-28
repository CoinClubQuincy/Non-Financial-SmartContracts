const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const uri = {
                "description": "Friendly OpenSea Creature that enjoys long swims in the ocean.", 
                "external_url": "https://openseacreatures.io/3", 
                "image": "https://storage.googleapis.com/opensea-prod.appspot.com/puffs/3.png", 
                "name": "Dave Starbelly",
                "attributes": [
                  {
                    "trait_type": "Base", 
                    "value": "Starfish"
                  }, 
                  {
                    "trait_type": "Eyes", 
                    "value": "Big"
                  }
                ]
              }
              
  console.log(
    "Deploying contracts with the account:",
    deployer.address
  );

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Admin = await hre.ethers.getContractFactory("Admin");
  const admin = await Admin.deploy("TestTokenization", "Test", 4, 3, "[place contract bytes]", "YourURI");

  await admin.deployed();

  console.log("Admin deployed to:", admin.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });