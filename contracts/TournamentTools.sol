// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;

/// @title Tournament
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of a Tournament bracket
/// @dev a free open source game counter

contract TournamentTools{
    function isInIntArray(uint[] memory array, uint value) public pure returns(bool) {
        for(uint i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }
    function isInAddressArray(address[] memory array, address value) public pure returns(bool) {
        for(uint i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }  
    function finalNaming(uint _bracketNumber) internal pure returns(string memory){
        if(_bracketNumber == 1){
            return ("Finals");
        } else if(_bracketNumber == 2){
            return ("Semi-Finals");
        } else if(_bracketNumber == 3){
            return ("Quarter-Finals");
        }
        return string(abi.encodePacked("Bracket","-",_bracketNumber));
    }
    function updateRating(uint winnerRating, uint loserRating) public pure returns (uint, uint) {
        uint K = 32;
        uint expectedWinner = 1 / (1 + 10 ** ((loserRating - winnerRating) / 400));
        uint expectedLoser = 1 / (1 + 10 ** ((winnerRating - loserRating) / 400));
        
        uint newWinnerRating = winnerRating + K * (1 - expectedWinner);
        uint newLoserRating = loserRating + K * (0 - expectedLoser);
        
        return (newWinnerRating, newLoserRating);
    }
}
