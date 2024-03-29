// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./Scoreboard.sol";

/// @title Tournament
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of a Tournament bracket
/// @dev a free open source game counter

abstract contract Tournament is Scoreboard,Client{
    uint public tournamentCounter = 0;

    mapping(uint => TournamentData) public tournament;
    mapping(uint => Bracket) public bracket;
    mapping(uint => Ratings) public ratings;

    event tournamentStatus(string _tournamentName,string status,string _msg);
    event teamClaimed(string _teamName,address _teamAddress,string _msg);

    struct TournamentData{
        string tournamentName;
        Bracket[] brackets;
        Ratings[] ratings;
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

    constructor(uint _totalKeys,string memory _URI) Scoreboard() Client(_totalKeys,address(0),true,_URI){}

    function createTournament(string memory _tournamentName,uint _totalPlayers) public onlyClient() returns(bool){
        require(tournament[tournamentCounter].exist == false, "Tournament already exists");
        
        (Bracket[] memory _bracket, Ratings[] memory _ratings) = createBrackets(tournamentCounter, _totalPlayers);
        
        TournamentData memory newTournament = TournamentData({
            tournamentName: _tournamentName,
            brackets: _bracket,
            ratings: _ratings,
            exist: true
        });

        tournament[tournamentCounter] = newTournament;
        tournamentCounter++;
        emit tournamentStatus(_tournamentName,"Tournament Created","Tournament has been created");
        return true;
    }
    function assignTeams(uint _tournamentNumber,uint _bracketNumber) public view onlyClient() returns(bool){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        require(tournament[_tournamentNumber].brackets[_bracketNumber].exist == true, "Bracket does not exist");

        Ratings[] memory _ratings = new Ratings[](tournament[_tournamentNumber].ratings.length);
        Games[] memory _games = new Games[](tournament[_tournamentNumber].brackets[_bracketNumber].games.length);
        Ratings[] memory _sortedRatings = sortRatings(tournament[_tournamentNumber].ratings);

        for(uint rates=0;rates <= tournament[_tournamentNumber].ratings.length ;rates++){
            _ratings[rates] = tournament[_tournamentNumber].ratings[rates];
        }

        for(uint i =0; i <= bracket[_bracketNumber].games.length; i++){
            _games[i] = bracket[_bracketNumber].games[i];
        }
        return true;
    }

    function isInArray(uint[] memory array, uint value) public pure returns(bool) {
        for(uint i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return true;
            }
        }
        return false;
    }

    function sortRatings(Ratings[] memory _rating) public pure returns(Ratings[] memory){
        uint n = _rating.length;
        for (uint i = 0; i < n-1; i++){
            for (uint j = 0; j < n-i-1; j++){
                if (_rating[j].rating < _rating[j+1].rating){
                    Ratings memory temp = _rating[j];
                    _rating[j] = _rating[j+1];
                    _rating[j+1] = temp;
                }
            }
        }
        return _rating;
    }

    function claimTeam(uint _tournamentNumber,string memory _teamName) public returns(bool){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        
        for(uint i = 0; i < tournament[_tournamentNumber].ratings.length; i++){
            if(tournament[_tournamentNumber].ratings[0].team.teamAddress == address(0)){
                tournament[_tournamentNumber].ratings[0].team.teamName = _teamName;
                tournament[_tournamentNumber].ratings[0].team.teamAddress = msg.sender;
                emit teamClaimed(_teamName,msg.sender,"Team has been claimed");
                return true;
            }
        }
        emit teamClaimed(_teamName,msg.sender,"Team unable to be claimed");
        return false;
    }

    function createBrackets(uint _tournamentNumber,uint _totalPlayers) internal returns(Bracket[] memory, Ratings[] memory){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        require(_totalPlayers > 0, "No players to create brackets");

        //generate Teams and Ratings
        Teams[] memory _teams = new Teams[](_totalPlayers);
        Ratings[] memory _ratings = new Ratings[](_totalPlayers);
        Bracket[] memory _brackets = new Bracket[](_totalPlayers);

        if(_totalPlayers % 2 != 0){     _totalPlayers++;    }   //if odd number of players, add one to make it even

        for(uint i = 0; i <= _totalPlayers; i++){
            Teams memory newTeam = Teams({
                teamName: string("Unclaimed Team"),
                teamAddress: address(0),
                teamData: ScoreData({
                    score: 0,
                    time: block.timestamp,
                    exist: true
                }),
                exist: true
            });
            _teams[i] = newTeam;

            Ratings memory newRating = Ratings({
                team: _teams[i],
                rating: 500,
                exist: true
            });

            ratings[i] = newRating;
        }

        uint bracketCount = 0;

        while (_totalPlayers > 2) {
            _totalPlayers = _totalPlayers / 2;
            bracketCount++;
        }

        string memory bracketName = finalNaming(0);
        
        for(uint bracks = 0; bracks <= bracketCount;bracks++){
            Games[] memory _games = new Games[]((bracks+1)*2);

            for (uint ngames=0; ngames <= (bracks+1)*2; ngames++){
                Games memory newGame = Games({
                    gameName: string(abi.encodePacked("Game-",ngames)),
                    teams: new Teams[](2),
                    isGameStarted: false,
                    exist: true,
                    winCondition: 0,
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
                _games[ngames] = newGame;
                bracks++;
            }

            Bracket memory newBracket = Bracket({
                tournamentNumber: _tournamentNumber,
                bracketName: bracketName,
                games: _games,
                isRoundStarted: false,
                exist: true,
                winner: Teams({
                    teamName: "No Winner",
                    teamAddress: address(0),
                    teamData: ScoreData({
                        score: 0,
                        time: block.timestamp,
                        exist: true
                    }),
                    exist: true
                })
            });
            _brackets[bracks] = newBracket;
        }
        return (_brackets,_ratings);
    }

    function viewAllTournaments() public view returns(TournamentData[] memory){
        TournamentData[] memory allTournaments = new TournamentData[](tournamentCounter);
        for(uint i = 0; i < tournamentCounter; i++){
            allTournaments[i] = tournament[i];
        }
        return allTournaments;
    }

    function tournamentDetails(uint _tournamentNumber) public view returns(TournamentData memory){
        return tournament[_tournamentNumber];
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