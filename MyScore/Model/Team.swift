//
//  Team.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Team : Codable {
    let team_id : Int
    let name : String
    let code : String?
    let logo : String?
    let country : String
    let founded : Int?
    let venue_name : String?
    let venue_surface : String?
    let venue_address : String?
    let venue_city : String?
    let venue_capacity : Int?
    
    
}

struct MatchTeam : Codable {
    let team_id : Int
    let team_name : String
    let logo : String
}
