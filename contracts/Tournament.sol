// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./Scoreboard.sol";

/// @title Tournament
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of a Tournament bracket
/// @dev a free open source game counter

contract Tournament is Scoreboard{
    uint public roundCounter = 0;

    mapping(uint => Round) public rounds;
    mapping(uint => TournamentData) public tournament;
    mapping(uint => Bracket) public bracket;
    mapping(uint => Ratings) public ratings;

    struct TournamentData{
        string tournamentName;
        Bracket[] brackets;
        bool exist;
    }

    struct Bracket{
        string bracketName;
        Round[] rounds;
        bool exist;
    }

    struct Round{
        string roundName;
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
        require(rounds[_roundNumber].isRoundStarted == true, "Round has not started");
        _;
    }

    constructor(string memory _tournamentName,uint _totalKeys,string memory _URI) Scoreboard(_tournamentName,_totalKeys,_URI){}

}