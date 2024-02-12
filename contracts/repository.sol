// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/IERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title GitXDC
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative

contract GitXDC is ERC1155 {
    uint public versionCount = 0;
    string public branch = "MAIN";
    string public name;
    string public description;
    uint public handlerToken = 0;
    uint public totalRepoKeys;
    uint public totalBranches = 0;
    uint public totalPullRequest = 0;
    uint public totalThreads = 0;
    //maybe place award amount havent mad mind up yet

    mapping(string => Repo) public repo;
    mapping(uint => Versions) public version;
    mapping(uint => AllPullRequest) public pull;
    mapping(uint => Branches) public fork;
    mapping(uint => Thread) public thread;

    event edit(uint _timestamp,string _msg, uint _version);
    event comment(string _title,string _comment);
    event GitXDCContractCreated(address indexed creator, address indexed gitXDCContract);

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
    struct Thread{
        string title;
        string description;
        Comment[] comments;
    }
    struct Comment{
        address user;
        string title;
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
        branch = _branch;
        versionCount++;
    }

    function editRepo(string _code, string _filename) public Handler returns(bool) {
        bool isNewFile = true;
        uint i;
        for(i = 0; i < repo[branch].versions[versionCount].filenames.length; i++) {
            if(repo[branch].versions[versionCount].filenames[i] == _filename) {
                repo[branch].versions[versionCount].code[i] = _code;
                isNewFile = false;
                break;
            }
        }
        if(isNewFile) {
            repo[branch].versions[versionCount].code.push(_code);
            repo[branch].versions[versionCount].filenames.push(_filename);
        }
        if(!isNewFile || (isNewFile && bytes(_code).length > 0)) {
            versionCount++;
            emit edit(block.timestamp, versionCount);
            return true;
        }
        return false;
    }
    //merge code from 3rd party contracts
    function mergePullRequest(address _repo,string _title,string _comments, bool _merge)public  Handler returns(bool){




        emit comment(_title,_comment);
        emit edit(block.timestamp,versionCount);
        return true;
    }
    //trigger pull request
    function openPullRequest(string memory _title, string memory _description)external returns(bool){
        pull[totalPullRequest] = AllPullRequest(msg.sender,_title,_description);
        thread[totalThreads] = Thread("New Pull Request: " + _title ,_description);

        totalThreads++;
        totalPullRequest++;
        emit comment("New Pull Request:",_description);
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
    function createFork(uint _version,string memory _branchName,string memory _repoName,uint _totalRepoKeys,string memory _description,_URI)public returns(bool){
        require(_branchName != "MAIN","you cant create a fork with the same branch name as MAIN");
        require(_branchName != branch,"you cant create a fork with the same branch name as the current fork");

        GitXDC newContract = new GitXDC(_repoName, _totalRepoKeys, _description,repo[branch].versions[_version].code, repo[branch].versions[_version].filenames,_URI,_branchName);

        fork[totalBranches] = Branches(newContract,_repoName,_description);
        emit GitXDCContractCreated(msg.sender, address(newContract));
        return true;
    }
    //allows people to clone software from the smart contract
    function cloneRepo(uint _version) public view returns (string[] memory, string[] memory) {
        return (repo[branch].versions[_version].code, repo[branch].versions[_version].filenames);
    }
}
