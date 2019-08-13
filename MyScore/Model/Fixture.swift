//
//  Fixtures.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Fixture : Codable {
    let fixture_id : Int
    let league_id: Int
    let event_date : String
    let event_timestamp : Int
    let firstHalfStart : Int?
    let secondHalfStart : Int?
    let round : String?
    let status : String
    let statusShort : String
    let elapsed : Int?
    let venue : String?
    let referee : String?
    let homeTeam : MatchTeam
    let awayTeam : MatchTeam
    let goalsHomeTeam : Int?
    let goalsAwayTeam : Int?
    let score : Score
    let lineups : [String : LineUp]?
    let statistics : [String : Amount]?
}
