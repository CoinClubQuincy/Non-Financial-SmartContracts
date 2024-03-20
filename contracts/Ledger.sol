// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./KeyManager.sol";

/// @title Ledger
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of each move in a game

abstract contract Ledger{
    Moves[] moves;
    address[] teams;
    uint public totalMoves = 0;
    uint public maxTeams;
    bool public multipleMoves;

    mapping(uint => Moves) public move;
    struct Moves{
        address team;
        string move;
        uint time;
        bool exist;
    }

    constructor(address[] memory _totalTeams, bool _multipleMoves) {
        require(_totalTeams.length > 0, "No teams have been added");
        teams = _totalTeams;
        multipleMoves = _multipleMoves;
        maxTeams = _totalTeams.length;
    }

    function getAllMoves() public view returns (Moves[] memory) {
        Moves[] memory allMoves = new Moves[](totalMoves);
        for (uint i = 0; i < totalMoves; i++) {
            allMoves[i] = move[i];
        }
        return allMoves;
    }

    function teamMoveOrder(uint _currentMove) public view returns (address) {
        require(_currentMove <= totalMoves, "No moves have been made");
        address teamsTurn;
        for(uint i = 0; i <= _currentMove; i++){
            if(i > maxTeams - 1){
                i = 0;
            }
            teamsTurn = teams[i];
        }
        return teamsTurn;
    }

    function makeMove(string memory _move) public virtual returns(bool){
        require(bytes(_move).length > 0, "Move cannot be empty");
        require(teamMoveOrder(totalMoves) == msg.sender, "It is not your turn");

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