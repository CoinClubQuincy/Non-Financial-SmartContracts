
// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./GeneralDeployer.sol";

/// @title Admin Key
/// @author R Quincy Jones
/// @notice this is a template that allows a single key to control multiple contracts
/// @dev a administrator key that can control multiple contracts

contract Admin is ERR1155{
    uint adminToken = 0;
    uint public keyLevelTotal = 2;
    ManagerDeployer public managerAddress;
    string public appName;
    string public appDescription;

    constructor(string memory _name,string memory _description,uint _keys,uint _keyLevel,bytes memory _managerContractBytes,string memory _URI)ERC1155(_URI) {
        require(_keys >= 4, "not enough keys for key level");
        require(keyLevel > 3, "key level not heigh enough");
        
        keyLevel = _keyLevel;
        appNAme = _name;
        appDescription = _description;

        managerAddress = new ManagerDeployer(_name,_description,true,_managerContractBytes);
        _mint(msg.sender, adminToken, _keys, "");
    }

    modifier onlyAdmin() {
        require(balanceOf(msg.sender, adminToken) > 0, "You are not the admin");
        _;
    }
    modifier keyLevel(uint _keyLevel){
        require(balanceOf(msg.sender, adminToken) > 0, "You are not the admin");   
        _; 
    }
    function createNewKey(uint _keys) public onlyAdmin keyLevel(keyLevelTotal) returns(bool){
        _mint(msg.sender, adminToken, _keys, "");
        return true;
    }
    function deleteKey(uint _keys) public onlyAdmin keyLevel(keyLevelTotal) returns(bool){
        _burn(msg.sender, adminToken, _keys);
        return true;
    }
    function changeKeyLevel(uint _keyLevel) public onlyAdmin keyLevel(keyLevelTotal + 1) returns(bool){
        keyLevelTotal = _keyLevel;
        return true;
    }
    function deployClientContract(string memory _name, string memory _description,bytes memory _constructorArgs)public returns(address){
        address clientAddress = managerAddress.createManager(_name, _description, clientContractBytes,_constructorArgs);
        return clientAddress;   
    }
}

/// @title Client Key
/// @author R Quincy Jones
/// @notice this is a template that allows a single key to control a single contract
/// @dev a free open source key manager

contract Client is ERR1155{
    uint clientToken = 0;
    Admin adminAddress;

    constructor(uint _keys,address _adminAddress,string memory _URI)ERC1155(_URI) {
        require(Admin(_adminAddress).isAdminContract(), "Provided address is not an Admin contract");
        _mint(msg.sender, clientToken, _keys, "");
        adminAddress = _adminAddress;
    }

    modifier onlyclient() {
        require(balanceOf(msg.sender, clientToken) > 0 || adminAddress.balanceOf(msg.sender, adminAddress.keyLevel(adminAddress.keyLevelTotal() + 1)) > 0, "You are not authorized");
        _;
    }
    function createNewKey(uint _keys) public onlyclient {
        _mint(msg.sender, clientToken, _keys, "");
    }
    function deleteKey(uint _keys) public onlyclient {
        _burn(msg.sender, clientToken, _keys);
    }
}