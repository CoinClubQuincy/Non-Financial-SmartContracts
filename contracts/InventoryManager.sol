// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./KeyManager.sol";
/// @title General Deployer
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative

contract InventoryManager is Client{
    constructor(uint _keys,address _adminAddress,string memory _URI) Client(_keys,_adminAddress,true,_URI){
        uri = _URI;
    }
    uint public totalTokens = 0;
    string public uri;
    using Strings for uint256;
    mapping(uint => InventoryLedger) inventoryLedger;
    struct InventoryLedger{
        string objectName;
        string objectDescription;
        uint objectID;
        uint objectAmmount;
        string url;
        bool isClaimed;
    }   

    function createToken(string memory _objectName,string memory _objectDescription,uint _objectAmmount,string memory _url) public onlyClient returns(bool){
        inventoryLedger[totalTokens] = InventoryLedger(_objectName,_objectDescription,totalTokens,_objectAmmount,_url,false);
        totalTokens++;
        _mint(address(this), totalTokens, _objectAmmount, "");
        return true;
    }
    function editToken(uint _token,string memory _objectName, string memory _objectDescription) onlyClient public returns(bool){
        inventoryLedger[_token].objectName = _objectName;
        inventoryLedger[_token].objectDescription = _objectDescription;
        return true;
    }
    function destroyToken(uint _token,uint _amount) public onlyClient returns(bool){
        require(balanceOf(address(this), _token) >= 1, "Token must be held in contract");
        _burn(address(this), _token,_amount);
        return true;
    }

    function redeemToken(address _user,uint _token) public onlyClient returns(bool,uint){
        require(inventoryLedger[_token].isClaimed = false, "Token has been claimed already");
        inventoryLedger[_token].isClaimed = true;
        safeTransferFrom(address(this), _user,_token ,  1, "");
        return (inventoryLedger[_token].isClaimed,_token);
    }

    function viewAllInventory() public view returns(InventoryLedger[] memory){
        InventoryLedger[] memory inventoryList = new InventoryLedger[](totalTokens);
        for (uint i = 0; i < totalTokens; i++) {
            inventoryList[i] = inventoryLedger[i];
        }
        return inventoryList;
    }

    function tokenURI(uint256 _tokenId) public view returns (string memory) {
        return string(abi.encodePacked(uri, _tokenId.toString()));
    }

    //ERC1155Received fuctions
    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }
}