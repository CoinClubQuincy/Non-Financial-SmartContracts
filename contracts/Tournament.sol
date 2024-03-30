// SPDX-License-Identifier: MIT License
pragma solidity ^0.8.9;
import "./Scoreboard.sol";
import "./TournamentTools.sol";
import "./KeyManager.sol";

/// @title Tournament
/// @author R Quincy Jones
/// @notice this is a contract that keeps track of a Tournament bracket
/// @dev a free open source game counter

contract Tournament is Scoreboard,Client,TournamentTools{
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
        require(_totalPlayers % 2 == 0, "player must be even number");
        
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
    function assignTeams(uint _tournamentNumber,uint _bracketNumber) public onlyClient() returns(bool){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        require(tournament[_tournamentNumber].brackets[_bracketNumber].exist == true, "Bracket does not exist");
        require(tournament[_tournamentNumber].ratings.length > 0, "No ratings to assign");

        Ratings[] memory _sortedRatings = sortRatings(tournament[_tournamentNumber].ratings);
        
        uint teamsCount = 0;
        for(uint _gameSort =0; _gameSort <= bracket[_bracketNumber].games.length; _gameSort++){
            tournament[_tournamentNumber].brackets[_bracketNumber].games[_gameSort].teams[teamsCount] = _sortedRatings[_gameSort].team;
            tournament[_tournamentNumber].brackets[_bracketNumber].games[_gameSort].teams[teamsCount] = _sortedRatings[bracket[_bracketNumber].games.length - teamsCount].team;
            teamsCount++;
        }
        return true;
    }

    function finalizeBracketStandings(uint _tournamentNumber,uint _bracketNumber) public onlyClient() returns(bool){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        require(tournament[_tournamentNumber].brackets[_bracketNumber].exist == true, "Bracket does not exist");
        require(tournament[_tournamentNumber].brackets[_bracketNumber].games.length > 0, "No games to finalize");

        for(uint i = 0; i < tournament[_tournamentNumber].brackets[_bracketNumber].games.length; i++){
            address player = tournament[_tournamentNumber].brackets[_bracketNumber].games[i].winner.teamAddress;
            if(player != address(0)){
                Ratings memory winnerRating = findRating(_tournamentNumber, player);
                updateRating(winnerRating.rating, winnerRating.rating + 100);
            }
        }
        return true;
    }

    function findRating(uint _tournamentNumber,address _teamAddress) public view returns(Ratings memory){
        require(tournament[_tournamentNumber].exist == true, "Tournament does not exist");
        for(uint i = 0; i < tournament[_tournamentNumber].ratings.length; i++){
            if(tournament[_tournamentNumber].ratings[i].team.teamAddress == _teamAddress){
                return tournament[_tournamentNumber].ratings[i];
            }
        }
        return Ratings({
            team: Teams({
                teamName: "No Team Exists",
                teamAddress: address(0),
                teamData: ScoreData({
                    score: 0,
                    time: 0,
                    exist: false
                }),
                exist: false
            }),
            rating: 0,
            exist: false
        });
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
}
