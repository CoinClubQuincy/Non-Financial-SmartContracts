// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./KeyManager.sol";

/// @title Game Scoreboard
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of score
/// @dev a free open source game counter

contract Scoreboard is Client{
    string public appName;
    uint public gameCounter = 0;
    mapping(string => Teams) public team;
    mapping(string => Games) public games;
    mapping(uint => Games) public gameList;

    event gameStatus(string _gameName,string status,string _msg);
    struct Games{
        string gameName;
        Teams[] teams;
        bool isGameStarted;
        bool exist;
        uint winCondition;
        Teams winner;
        bool isOver;
    }

    struct Teams{
        string teamName;
        ScoreData teamData;
        bool exist;
    }

    struct ScoreData{
        uint score;
        uint time;
        bool exist;
    }

    constructor(string memory _appName,uint _totalKeys,string memory _URI) Client(_totalKeys, 0x0000000000000000000000000000000000000000, false, _URI) {
        appName = _appName;
    }

    modifier gameStarted(string memory _gameName){
        require(games[_gameName].isGameStarted == true, "Game has not started");
        _;
    }

    function createGame(string memory _gameName,uint _winCondition) public onlyClient() returns(bool){
        require(games[_gameName].exist == false, "Game already exists");
        Games memory newGame = Games({
            gameName: _gameName,
            teams: new Teams[](0),
            isGameStarted: false,
            exist: true,
            winCondition: _winCondition,
            winner: Teams({
                teamName: "No Winner",
                teamData: ScoreData({
                    score: 0,
                    time: block.timestamp,
                    exist: true
                }),
                exist: true
            }),
            isOver: false
        });

        emit gameStatus(_gameName, "New Game","Game has been created");
        gameList[gameCounter] = newGame;
        games[_gameName] = newGame;
        gameCounter++;
        return true;
    }

    function createTeam(string memory _gameName,string memory _teamName) public onlyClient() gameStarted(_gameName) returns(bool){
        require(team[_teamName].exist == false, "Team already exist");
        team[_teamName] = Teams({
            teamName: _teamName,
            teamData: ScoreData({
                score: 0,
                time: block.timestamp,
                exist: true
            }),
            exist: true
        });

        games[_gameName].teams.push(team[_teamName]);
        emit gameStatus(_gameName, _teamName,"Team has been created");
        return true;
    }

    function startGame(string memory _gameName) public onlyClient() gameStarted(_gameName) returns(bool){
        games[_gameName].isGameStarted = true;
        emit gameStatus(_gameName, "New Game","Game has started");
        return true;
    }

    function score(string memory _gameName,string memory _teamName,uint _score,bool _allocation) public onlyClient() gameStarted(_gameName) returns(bool){
        require(team[_teamName].exist == true, "Team does not exist");
        if (_allocation == true) {
            team[_teamName].teamData.score += _score;
            isOver(_teamName);
            emit gameStatus(_gameName,_teamName,"Team Scored");
        } else {
            team[_teamName].teamData.score -= _score;
            emit gameStatus(_gameName,_teamName,"Team loss points");
        }
        return true;
    }
    
    function viewAllGames() public view returns(Games[] memory){
        Games[] memory fullGameList = new Games[](gameCounter);
        for(uint i = 0; i < gameCounter; i++){
            fullGameList[i] = gameList[i];
        }
        return fullGameList;
    }
    
    function viewGame(string memory _gameName) public view returns(Games memory){
        return games[_gameName];
    }

    function viewAllTeams(string memory _gameName) public view returns(Teams[] memory){
        return games[_gameName].teams;
    }

    function isOver(string memory _teamName) internal {
        if(team[_teamName].teamData.score == games[appName].winCondition){
            games[appName].isOver = true;
            games[appName].winner = team[_teamName];
        }
    }

    function defaultWinner(string memory _gameName,string memory _teamName) public onlyClient() gameStarted(_gameName) returns(bool){
        require(games[_gameName].isOver == false, "Game is already over");
        require(games[_gameName].exist == true, "Game does not exist");
        require(team[_teamName].exist == true, "Team does not exist");

        games[_gameName].isOver = true;
        games[_gameName].winner = team[_teamName];
        return true;
    }
}

