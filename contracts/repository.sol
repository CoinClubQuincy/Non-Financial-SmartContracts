// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/IERC20/IERC20.sol";


/// @title GitXDC
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative

contract GitXDC is ERC1155 {
    uint versionCount = 0;
    uint branch = 0;
    string description;

    mapping(uint => Repo) public repo;
    mapping(uint => Versions) public version;
    mapping(string => Branches) public branch;
    mapping(uint => Branches) public branch;

    event edit(uint _timestamp,_msg, uint _version);

    struct Repo {
        string name;
        Versions[] versions;
    }

    struct Versions {
        string[] code;
        string[] filenames;
        uint versionNumber;
    }

    struct Branches{
        string branch;
    }

    struct AllPullRequest{
        address repo;
        string title;
        string messeage;
    }


    modifier Handler{

        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)

    constructor(string memory _repoName,string memory _description, string[] memory _code, string[] memory _filenames,_URI) ERC1155(_URI) {
        name = _repoName;
        description = _description;
        version[versionCount] = Versions(_code, _filenames, versionCount);
        repo[branch] = Repo(_repoName, version[versionCount]);
        versionCount++;
    }

    function editRepo(uint _branch,string _code,string _filename) public Handler returns(bool,uint){
        for(uint i = 0;i < repo[_branch].versions[_version].filenames.length;i++){
            if(repo[_branch].versions[_version].filenames[i] == _filename){
                repo[_branch].versions[_version].code[i] = _code;
                repo[_branch].versions[_version].filenames[i] = _filename;
            }
        }
        versionCount++;

        emit edit(block.timestamp,versionCount);
        return (true,versionCount);
    }

    function ApproovePullRequest(address _repo)public  Handler returns(bool){}


    function OpenPullRequest(address _repo,string memory _title, string memory _description)public returns(bool){}
    function ViewAllPullRequest()public view returns(bool){}

    function CloneRepo(uint _branch, uint _version) public view returns (string[] memory, string[] memory) {
        return (repo[_branch].versions[_version].code, repo[_branch].versions[_version].filenames);
    }
}
