// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

/// @title Repository
/// @author R Quincy Jones
/// @notice this is a repository stored on chain to version code
/// @dev a free open source github alternative

contract Repository is ERC1155 {
    uint public versionCount = 0;
    string public branch = "MAIN";
    string public name;
    string public description;
    uint public handlerToken = 0;
    uint public totalRepoKeys;
    uint public totalBranches = 0;
    uint public totalPullRequest = 0;
    uint public totalThreads = 0;

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
        uint version;
    }

    struct Branches{
        address contracts;
        string branchName;
        string description;
    }
    struct Thread{
        string title;
        string description;
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

    constructor(string memory _repoName,uint _totalRepoKeys,string memory _description,string memory _URI,string memory _branch) ERC1155(_URI) {
        _mint(msg.sender, handlerToken,_totalRepoKeys, "");

        totalRepoKeys = _totalRepoKeys;
        name = _repoName;
        description = _description;
        branch = _branch;
    }

    function editRepo(string[] memory _code, string[] memory _filenames) public Handler returns(bool) {
        require(_code.length == _filenames.length, "Code and filenames arrays must have the same length");
        for(uint i = 0; i < _code.length; i++) {
            bool isNewFile = true;
            for(uint j = 0; j < repo[branch].versions[versionCount].filenames.length; j++) {
                if(keccak256(abi.encodePacked(repo[branch].versions[versionCount].filenames[j])) == keccak256(abi.encodePacked(_filenames[i]))) {
                    repo[branch].versions[versionCount].code[j] = _code[i];
                    isNewFile = false;
                    break;
                }
            }
            if(isNewFile) {
                repo[branch].versions[versionCount].code.push(_code[i]);
                repo[branch].versions[versionCount].filenames.push(_filenames[i]);
            }
        }
        versionCount++;
        emit edit(block.timestamp, "Edited multiple files", versionCount);
        return true;
    }
    //merge code from 3rd party contracts
    function mergePullRequest(address _repo, string memory _title, string memory _comments) public Handler returns(bool) {
        for(uint i = 0; i < totalPullRequest; i++) {
            if(pull[i].repo == _repo && keccak256(abi.encodePacked(pull[i].title)) == keccak256(abi.encodePacked(_title))) {

                (string[] memory code, string[] memory filenames) = Repository(_repo).cloneRepo(pull[i].version);
                
                for(uint j = 0; j < code.length; j++) {
                    editRepo(code[j], filenames[j]);
                }
            
                emit comment(_title, _comments);
                emit edit(block.timestamp,"merg pull request",versionCount);
                return true;
            }
        }
        return false;
    }
    //trigger pull request
    function openPullRequest(string memory _title, string memory _description,uint _version,address _contract)external returns(bool){
        pull[totalPullRequest] = AllPullRequest(_contract,_title,_description,_version);
        thread[totalThreads] = Thread(string(abi.encodePacked("New Pull Request: " , _title)),_description);

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
    function createFork(uint _version,string memory _branchName,string memory _repoName,uint _totalRepoKeys,string memory _description,string memory _URI)public returns(bool){
        require(_branchName != "MAIN","you cant create a fork with the same branch name as MAIN");
        require(_branchName != branch,"you cant create a fork with the same branch name as the current fork");

        Repository newContract = new Repository(_repoName, _totalRepoKeys, _description,_URI,_branchName);

        fork[totalBranches] = Branches(address(newContract),_repoName,_description);
        emit GitXDCContractCreated(msg.sender, address(newContract));
        return true;
    }
    //allows people to clone software from the smart contract
    function cloneRepo(uint _version) public view returns (string[] memory, string[] memory) {
        return (repo[branch].versions[_version].code, repo[branch].versions[_version].filenames);
    }
}
