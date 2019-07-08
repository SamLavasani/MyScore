//
//  Competition.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit


// MARK: - Request Response Structs
struct CompetitionsResponse : Codable {
    let competitions : [Competition]
}

struct MatchesResponse : Codable {
    let matches : [Match]
}

struct CompetitionDetailsResponse : Codable {
    let competition : Competition
    let matches : [Match]
    
}

struct TeamDetailsResponse : Codable {
    let id : Int
    let name : String
    let squad : [Player]
    
}

struct TableStandingsResponse : Codable {
    let competition : Competition
    let season : Season
    let standings : [TableStandings]
}

// MARK: - Decodable Structs

struct TableStandings : Codable {
    let group : String?
    let stage : String?
    var table : [TeamPosition]
    let type : String
}

struct TeamPosition : Codable {
    let position : Int
    let team : Team
    let playedGames : Int
    let won : Int
    let draw : Int
    let points : Int
    let goalsFor : Int
    let goalsAgainst : Int
    let goalDifference : Int
}

struct Team : Codable {
    let id : Int
    let name : String
    let venue : String?
    let crestUrl : String?
    let website : String?
}

struct DateInfo {
    var date : String = ""
    var time : String = ""
}

struct Competition : Codable {
    let id : Int
    let area : Area?
    let name : String
    let currentSeason : Season?
}

struct Area : Codable {
    let id : Int
    let name : String
}

struct Match : Codable {
    let id : Int
    let competition : Competition?
    let status : String
    let minute : Int?
    let homeTeam : MatchTeam
    let awayTeam : MatchTeam
    let utcDate : String
}

struct MatchTeam : Codable {
    let id : Int
    let name : String
    let coach : Coach?
    let captain : Captain?
    let lineUp : [Player]?
    let bench : [Player]?
}

struct Coach : Codable {
    let id : Int
    let name : String
}

struct Score : Codable {
    let minute : Int
    
}

struct Goals : Codable {
    let minute : Int
    let scorer : Player
    let assist : Player
}

struct Captain : Codable {
    let id : Int
    let name : String
    let shirtNumber : String
}

struct Season : Codable {
    let id : Int
    let startDate : String
    let endDate : String
}

struct Squad : Codable {
    let squad : [Player]
}

struct Player : Codable {
    let id : Int
    let name : String
    let firstName : String?
    let lastName : String?
    let shirtNumber : Int?
    let dateOfBirth : String
    let countryOfBirth : String
    let nationality : String
    let position : String?
    let role : String?
}


