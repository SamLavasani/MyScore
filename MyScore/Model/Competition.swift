//
//  Competition.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit


// MARK: - Request Response Structs
struct CompetitionsResponse : Decodable {
    var competitions : [Competition]
}

struct CompetitionDetailsResponse : Decodable {
    var competition : Competition
    var matches : [Matches]
    
}

struct TableStandingsResponse : Decodable {
    var competition : Competition
    var season : Season
    var standings : [TableStandings]
}

// MARK: - Decodable Structs

struct TableStandings : Decodable {
    var group : String?
    var stage : String?
    var table : [TeamPosition]
    var type : String
}

struct TeamPosition : Decodable {
    var position : Int
    var team : Team
    var playedGames : Int
    var won : Int
    var draw : Int
    var points : Int
    var goalsFor : Int
    var goalsAgainst : Int
    var goalDifference : Int
}

struct Team : Decodable {
    var id : Int
    var name : String
    var venue : String?
    var crestUrl : String?
    var website : String?
}

struct DateInfo {
    var date : String = ""
    var time : String = ""
}

struct Competition : Decodable {
    var id : Int
    var area : Area
    var name : String
    var currentSeason : Season?
}

struct Area : Decodable {
    var id : Int
    var name : String
}

struct Matches : Decodable {
    var id : Int
    var status : String
    var homeTeam : MatchTeam
    var awayTeam : MatchTeam
    var utcDate : String
}

struct MatchTeam : Decodable {
    var id : Int
    var name : String
    var coach : Coach?
    var captain : Captain?
    var lineUp : [MatchPlayer]?
    var bench : [MatchPlayer]?
    
}

struct Coach : Decodable {
    var id : Int
    var name : String
}

struct Captain : Decodable {
    var id : Int
    var name : String
    var shirtNumber : String
}

struct Season : Decodable {
    var id : Int
    var startDate : String
    var endDate : String
}

struct MatchPlayer : Decodable {
    var id : Int
    var name : String
    var position : String
    var shirtNumber : Int
}

struct Player : Decodable {
    var id : Int
    var name : String
    var firstName : String
    var lastName : String?
    var dateOfBirth : String
    var countryOfBirth : String
    var nationality : String
    var position : String
}


