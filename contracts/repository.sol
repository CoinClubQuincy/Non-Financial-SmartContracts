//SPDX-License-Identifier: MIT License

pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/IERC20/IERC20.sol";

contract repo{
    struct storeData{
        string name;
        string[] code;
        string[] filenames;
    }
    function createRepo(string _repoName, string[] _code,string[] _filenames) public returns(bool){
        return true;
    }
    function editRepo(string _code,string _filenames) public returns(bool){
        return true;
    }
    function pullCode(string _repoName) public view returns(bool){
        return true;
    }
} 