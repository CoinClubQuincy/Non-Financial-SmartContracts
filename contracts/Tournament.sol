// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./Scoreboard.sol";

/// @title Tournament
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of a Tournament bracket
/// @dev a free open source game counter

contract Tournament is Scoreboard{
    uint public roundCounter = 0;

    mapping(uint => TournamentData) public tournament;
    mapping(string => TournamentData) public tournamentName;
    mapping(uint => Bracket) public bracket;
    mapping(uint => Ratings) public ratings;

    struct TournamentData{
        string tournamentName;
        Bracket[] brackets;
        bool exist;
    }

    struct Bracket{
        uint tournamentNumber;
        string bracketName;
        Games[] games;
        bool isRoundStarted;
        bool exist;
        Teams winner;
    }
    
    struct Ratings{
        Teams team;
        uint rating;
        bool exist;
    }

    modifier roundStarted(uint _roundNumber){
        require(bracket[_roundNumber].isRoundStarted == true, "Round has not started");
        _;
    }

    constructor(string memory _tournamentName,uint _totalKeys,string memory _URI) Scoreboard(_tournamentName,_totalKeys,_URI){}

    function createTournament(string memory _tournamentName) public onlyClient() returns(bool){
        require(tournament[roundCounter].exist == false, "Tournament already exists");
        TournamentData memory newTournament = TournamentData({
            tournamentName: _tournamentName,
            brackets: new Bracket[](0),
            exist: true
        });

        tournament[roundCounter] = newTournament;
        tournamentName[_tournamentName] = newTournament;
        return true;
    }

    function creeateBrackets(uint _tournamentNumber,uint _totalPlayers,uint _totalBrackets) internal onlyClient() returns(bool){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        require(bracket[_tournamentNumber].exist == false, "Bracket already exists");
        require(_totalPlayers >= 8, "Not enough players");

        //generate rounds for bracket
        uint rounds = 0;
        for(uint i = 1; i < _totalPlayers; i++){
            (string memory bracketName,uint bracketNumb) = finalNaming(i);
            if(bracketNumb > 3){
                bracketName = string(abi.encodePacked(bracketName,"-",bracketName));
            }

            Games memory newGame = Games({
                gameName: string(abi.encodePacked("Game-",i)),
                teams: new Teams[](0),
                isGameStarted: false,
                exist: true,
                winCondition: 0,
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

            Bracket memory newBracket = Bracket({
                tournamentNumber: _tournamentNumber,
                bracketName: bracketName,
                games: new Games[](0),
                isRoundStarted: false,
                exist: true,
                winner: Teams({
                    teamName: "No Winner",
                    teamData: ScoreData({
                        score: 0,
                        time: block.timestamp,
                        exist: true
                    }),
                    exist: true
                })
            });

            tournament[_tournamentNumber].brackets.push(newBracket);
        }

        return true;
    }

    function viewAllTournaments() public view returns(TournamentData[] memory){
        TournamentData[] memory allTournaments = new TournamentData[](roundCounter);
        for(uint i = 0; i < roundCounter; i++){
            allTournaments[i] = tournament[i];
        }
        return allTournaments;
    }

    function tournamentDetails(uint _tournamentNumber) public view returns(TournamentData memory){
        return tournament[_tournamentNumber];
    }

    function finalNaming(uint _bracketNumber) internal pure returns(string memory,uint){
        if(_bracketNumber == 1){
            return ("Finals",_bracketNumber);
        } else if(_bracketNumber == 2){
            return ("Semi-Finals",_bracketNumber);
        } else if(_bracketNumber == 3){
            return ("Quarter-Finals",_bracketNumber);
        }
        return ("Bracket",_bracketNumber);
    }
}