// Import the Web3 library
const Web3 = require('web3');

// Define the HTTP provider, for example, the local Ethereum node
const httpProvider = 'http://localhost:8545';

// Create an instance of Web3 with the HTTP provider
var web3 = new Web3(httpProvider);

const Web3 = require('web3');

// Use Infura endpoint
const infuraUrl = 'https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID';

web3 = new Web3(infuraUrl);

// Initialize web3
if (window.ethereum) {
    window.web3 = new Web3(ethereum);
    try {
        // Request account access
        await ethereum.enable();
    } catch (error) {
        console.error("User denied account access")
    }
} else if (window.web3) {
    window.web3 = new Web3(web3.currentProvider);
} else {
    console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
}

// Get accounts
const accounts = await web3.eth.getAccounts();

// Set up contract
const contract = new web3.eth.Contract(abi, contractAddress);

// Call a function
const result = await contract.methods.myMethod().call({from: accounts[0]});

// Or send a transaction
const receipt = await contract.methods.myMethod().send({from: accounts[0]});