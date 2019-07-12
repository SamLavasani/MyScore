//
//  Standing.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Standing : Codable {
    let rank : Int
    let team_id : Int
    let teamName : String
    let logo : String
    let group : String
    let forme : String?
    let description : String?
    let all : StandingInfo?
    let home : StandingInfo?
    let away : StandingInfo?
    let goalsDiff : Int
    let points : Int
    let lastUpdate : String
}

struct StandingInfo : Codable {
    let matchsPlayed : Int
    let win : Int
    let draw : Int
    let lose : Int
    let goalsFor : Int
    let goalsAgainst : Int
}
