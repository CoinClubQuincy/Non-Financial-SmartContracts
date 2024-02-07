// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/IERC20/IERC20.sol";


/// @title GitXDC
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative

contract GitXDC is ERC1155 {
    uint public versionCount = 0;
    string public branch = "MAIN";
    string public description;
    string public handlerToken = 0;
    uint public totalRepoKeys;
    uint public totalBranches = 0;
    uint public totalPullRequest = 0;
    //maybe place award amount havent mad mind up yet

    mapping(string => Repo) public repo;
    mapping(uint => Versions) public version;
    mapping(uint => AllPullRequest) public pull;
    mapping(uint => Branches) public fork;

    event edit(uint _timestamp,_msg, uint _version);
    event comment(_title,_comment);
    event GitXDCContractCreated(address indexed creator, address indexed gitXDCContract, uint initialData);

    struct Repo {
        string name;
        Versions[] versions;
    }

    struct Versions {
        string[] code;
        string[] filenames;
        uint versionNumber;
    }

    struct AllPullRequest{
        address repo;
        string title;
        string messeage;
    }

    struct Branches{
        address contracts;
        string branchName;
        string description;
    }

    //check to see it user has repo key
    modifier Handler{
        require(balanceOf(msg.sender,handlerToken) >= 1, "currently do not hold repo key");
        _;
    }

    /// @notice Explain to an end user what this does
    /// @dev Explain to a developer any extra details
    /// @param Documents a parameter just like in doxygen (must be followed by parameter name)
    /// @return Documents the return variables of a contract’s function state variable
    /// @inheritdoc	Copies all missing tags from the base function (must be followed by the contract name)

    constructor(string memory _repoName,uint _totalRepoKeys,string memory _description, string[] memory _code, string[] memory _filenames,_URI,_branch) ERC1155(_URI) {
        _mint(msg.sender, handlerToken,_totalRepoKeys, "");

        totalRepoKeys = _totalRepoKeys;
        name = _repoName;
        description = _description;

        version[versionCount] = Versions(_code, _filenames, versionCount);
        repo[branch] = Repo(_repoName, version[versionCount]);
        branch == _branch;
        versionCount++;
    }

    function editRepo(string _code,string _filename) public Handler returns(bool){
        //add ability to save multiple files at the same time
        bool isNewFile = true;
        //checks to see if file is present and edits the code
        for(uint i = 0;i < repo[branch].versions[_version].filenames.length;i++){
            if(repo[branch].versions[_version].filenames[i] == _filename){
                repo[branch].versions[_version].code[i] = _code;
                isNewFile = false;
            } 
            // if file is not found create file and place code as next item in array
            //runs if code if file is not found
            if(i == repo[branch].versions[_version].filenames.length && isNewFile == true){
                repo[branch].versions[_version].code[i+1] = _code;
                repo[branch].versions[_version].filenames[i+1] = _filename;
            }
        }
        versionCount++;
        emit edit(block.timestamp,versionCount);
        return (true);
    }
    //merge code from 3rd party contracts
    function mergePullRequest(address _repo,string _title,string _comments, bool _merge)public  Handler returns(bool){

        emit comment(_title,_comment);
        emit edit(block.timestamp,versionCount);
        return true;
    }
    //make pull request
    function makePullRequest()public returns(bool){
        return true;
    }
    //trigger pull request
    function openPullRequest(address _repo,string memory _title, string memory _description)external returns(bool){
        totalPullRequest++;
        return true;
    }
    //view all pull request
    function viewAllPullRequests() public view returns (AllPullRequest[] memory) {
        AllPullRequest[] memory pullRequestsList = new AllPullRequest[](totalPullRequest);
        for (uint i = 0; i < totalPullRequest; i++) {
            pullRequestsList[i] = pull[i];
        }
        return pullRequestsList;
    }
    //view all generated contracts that have forked a current version of the code
    function viewAllForks() public view returns (Branches[] memory) {
        Branches[] memory branchesList = new Branches[](totalBranches);
        for (uint i = 0; i < totalBranches; i++) {
            branchesList[i] = fork[i];
        }
        return branchesList;
    }
    //generates a new contract with version of code inside
    function createFork(string memory _branchName,string memory _repoName,uint _totalRepoKeys,string memory _description,_URI)public returns(bool){
        require(_branchName != "MAIN","you cant create a fork with the same branch name as MAIN");
        require(_branchName != branch,"you cant create a fork with the same branch name as the current fork");

        GitXDC newContract = new GitXDC(_repoName, _totalRepoKeys, _description,repo[branch].versions[_version].code, repo[branch].versions[_version].filenames,_URI,_branchName);
        fork[totalBranches] = Branches(newContract,_repoName,_description);
        emit GitXDCContractCreated(msg.sender, address(newContract), _initialData);
        return true;
    }
    //allows people to clone software from the smart contract
    function cloneRepo(uint _version) public view returns (string[] memory, string[] memory) {
        return (repo[branch].versions[_version].code, repo[branch].versions[_version].filenames);
    }
}
