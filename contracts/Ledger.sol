// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./KeyManager.sol";

/// @title Ledger
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of each move in a game

abstract contract Ledger{
    uint totalRounds = 0;

    mapping(uint => Moves) public move;
    mapping(uint => MoveLedger) private eachRound;
    struct Moves{
        address team;
        string move;
        uint time;
        bool exist;
    }

    struct MoveLedger{
        Moves[] moves;
        address[] teams;
    }
    function getAllMoves() public view returns (Moves[] memory) {
        Moves[] memory allMoves = new Moves[](totalRounds);
        for (uint i = 0; i < totalRounds; i++) {
            allMoves[i] = eachRound[i].moves;
        }
        return allMoves;
    }

    function getAllTeams() public view returns (address[] memory) {
        address[] memory allTeams = new address[](totalRounds);
        for (uint i = 0; i < totalRounds; i++) {
            allTeams[i] = eachRound[i].teams;
        }
        return allTeams;
    }
}