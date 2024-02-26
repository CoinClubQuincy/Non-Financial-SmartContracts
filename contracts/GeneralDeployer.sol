
// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/IERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title General Deployer
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative


contract ManagerDeployer{
    uint public totalContracts = 0;
    string public deployerName;
    string public deployerDescription;
    string public singleContractABI;
    bool public singleDeployerActive = false;

    event createNewRepo(address indexed creator, address indexed gitXDCContract);

    mapping(uint => Repo) public repos;
    struct Managers {
        string name;
        string description;
        address contractAddress;
    }

    constructor(string memory _name, string memory _description,bool _singleDeployerActive, string memory _singleContractABI) {
        deployerName = _name;
        deployerDescription = _description;
        singleDeployerActive = _singleDeployerActive;
        singleContractABI = _singleContractABI;
    }

    modifier singleDeployer(_deployedSingleContractABI) {
        if(singleDeployerActive == true){ require(singleContractABI == _deployedSingleContractABI, "this deployer can only deploy a single contract type");}
        _;
    }

    function createManager(string memory _name, string memory _description, bytes memory _contractByteCode, bytes memory _constructorArgs) public singleDeployer(_contractByteCode)  returns(address) {
        bytes memory bytecodeWithConstructorArgs = abi.encodePacked(_contractByteCode, _constructorArgs);
        address newContract = createChild(bytecodeWithConstructorArgs);
        repos[totalContracts] = Repo(_name, _description, newContract);
        emit createNewRepo(msg.sender, newContract);
        return newContract;
    }

    function createChild(bytes memory bytecode) internal returns (address) {
        address child;
        assembly {
            child := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return child;
    }

    function viewAllContracts() public view returns (Repo[] memory) {
        Repo[] memory reposList = new Repo[](totalContracts);
        for (uint i = 0; i < totalContracts; i++) {
            reposList[i] = repos[i];
        }
        return reposList;
    }
}