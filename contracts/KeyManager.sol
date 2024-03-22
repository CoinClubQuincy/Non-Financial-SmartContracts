// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./GeneralDeployer.sol";

/// @title Admin Key
/// @author R Quincy Jones
/// @notice this is a template that allows a single key to control multiple contracts
/// @dev a administrator key that can control multiple contracts

contract Admin is ERC1155{
    uint public adminToken;
    uint public keyLevelTotal = 2;
    ManagerDeployer public managerAddress;
    string public appName;
    string public appDescription;
    bool public isAdminContract = true;

    constructor(string memory _name,string memory _description,uint _keys,uint _keyLevel,bytes memory _managerContractBytes,string memory _URI)ERC1155(_URI) {
        require(_keys >= 4, "not enough keys for key level");
        require(keyLevelTotal > 3, "key level not heigh enough");
        
        keyLevelTotal = _keyLevel;
        appName = _name;
        appDescription = _description;

        adminToken = uint256(keccak256(abi.encodePacked(block.timestamp)));
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
    function deployClientContract(string memory _name, string memory _description,bytes memory _clientContractBytes,bytes memory _constructorArgs)public  onlyAdmin keyLevel(keyLevelTotal + 1) returns(address){
        address clientAddress = managerAddress.createManager(_name, _description, _clientContractBytes,_constructorArgs);
        return clientAddress;   
    }
}

/// @title Client Key
/// @author R Quincy Jones
/// @notice this is a template that allows a single key to control a single contract
/// @dev a free open source key manager

contract Client is ERC1155{
    uint public clientToken;
    Admin public adminAddress;
    bool public isHandler;

    constructor(uint _keys,address _adminAddress,bool _isHandler ,string memory _URI)ERC1155(_URI) {
        if(_isHandler == false){ require(Admin(_adminAddress).isAdminContract(), "Provided address is not an Admin contract"); }
        _mint(msg.sender, clientToken, _keys, "");
        adminAddress = Admin(_adminAddress);
        isHandler = _isHandler;
        clientToken = uint256(keccak256(abi.encodePacked(block.timestamp)));
    }

    modifier onlyClient() {
        require(balanceOf(msg.sender, clientToken) > 0 || adminAddress.balanceOf(msg.sender,adminAddress.adminToken()) >= adminAddress.keyLevelTotal(), "You are not authorized");
        _;
    }
    function createNewKey(uint _keys) public onlyClient {
        _mint(msg.sender, clientToken, _keys, "");
    }
    function deleteKey(uint _keys) public onlyClient {
        _burn(msg.sender, clientToken, _keys);
    }
}