// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./KeyManager.sol";

/// @title Game Scoreboard
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of score
/// @dev a free open source game counter

contract Scoreboard{
    uint public gameCounter = 0;
    string public scoreboard = "Default";

    mapping(address => Teams) public team;
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
        address teamAddress;
        ScoreData teamData;
        bool exist;
    }

    struct ScoreData{
        uint score;
        uint time;
        bool exist;
    }

    modifier gameStarted(string memory _gameName){
        require(games[_gameName].isGameStarted == true, "Game has not started");
        _;
    }

    function createGame(string memory _gameName,uint _winCondition) internal virtual returns(bool){
        require(games[_gameName].exist == false, "Game already exists");
        Games memory newGame = Games({
            gameName: _gameName,
            teams: new Teams[](0),
            isGameStarted: false,
            exist: true,
            winCondition: _winCondition,
            winner: Teams({
                teamName: "No Winner",
                teamAddress: address(0),
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

    function createTeam(string memory _gameName,string memory _teamName) internal virtual gameStarted(_gameName) returns(bool){
        require(team[msg.sender].exist == false, "Team already exist");
        team[msg.sender] = Teams({
            teamName: _teamName,
            teamAddress: msg.sender,
            teamData: ScoreData({
                score: 0,
                time: block.timestamp,
                exist: true
            }),
            exist: true
        });

        games[_gameName].teams.push(team[msg.sender]);
        emit gameStatus(_gameName, _teamName,"Team has been created");
        return true;
    }

    function startGame(string memory _gameName) internal virtual gameStarted(_gameName) returns(bool){
        games[_gameName].isGameStarted = true;
        emit gameStatus(_gameName, "New Game","Game has started");
        return true;
    }

    function score(string memory _gameName,uint _score,bool _allocation) internal virtual gameStarted(_gameName) returns(bool){
        require(team[msg.sender].exist == true, "Team does not exist");
        if (_allocation == true) {
            team[msg.sender].teamData.score += _score;
            isOver(msg.sender);
            emit gameStatus(_gameName,team[msg.sender].teamName,"Team Scored");
        } else {
            team[msg.sender].teamData.score -= _score;
            emit gameStatus(_gameName,team[msg.sender].teamName,"Team loss points");
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

    function isOver(address _team) internal {
        if(team[_team].teamData.score == games[scoreboard].winCondition){
            games[scoreboard].isOver = true;
            games[scoreboard].winner = team[_team];
        }
    }

    function defaultWinner(string memory _gameName,address _team) internal virtual gameStarted(_gameName) returns(bool){
        require(games[_gameName].isOver == false, "Game is already over");
        require(games[_gameName].exist == true, "Game does not exist");
        require(team[_team].exist == true, "Team does not exist");

        games[_gameName].isOver = true;
        games[_gameName].winner = team[_team];
        return true;
    }
}

