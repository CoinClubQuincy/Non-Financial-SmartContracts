// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./KeyManager.sol";

/// @title Ledger
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of each move in a game

abstract contract Ledger{
    uint totalMoves = 0;
    Moves[] moves;
    address[] teams;
    uint public maxTeams = 2;

    mapping(uint => Moves) public move;
    struct Moves{
        address team;
        string move;
        uint time;
        bool exist;
    }

    constructor(address[] memory _totalTeams) {
        require(_totalTeams.length > 0, "No teams have been added");
        require(_totalTeams.length == maxTeams, "Only two teams are allowed");
        teams = _totalTeams;
    }

    modifier toggleTeamTurn(address _teamName){
        require(_teamName == teams[0] || _teamName == teams[1], "Team not authorized");
        require(teams.length > 0, "No teams have been added");
        require(maxTeams < teams.length, "All teams have made a move");
        require(keccak256(abi.encodePacked(move[totalMoves - 1].team)) == keccak256(abi.encodePacked(_teamName)), "It is not your turn");
        _;
    }

    function getAllMoves() public view returns (Moves[] memory) {
        Moves[] memory allMoves = new Moves[](totalMoves);
        for (uint i = 0; i < totalMoves; i++) {
            allMoves[i] = move[i];
        }
        return allMoves;
    }

    function makeMove(string memory _move) public virtual toggleTeamTurn(msg.sender) returns(bool){
        require(bytes(_move).length > 0, "Move cannot be empty");

        Moves memory newMove = Moves({
            team: msg.sender,
            move: _move,
            time: block.timestamp,
            exist: true
        });

        move[totalMoves] = newMove;
        totalMoves++;
        return true;
    }
}