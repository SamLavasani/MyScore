//
//  Event.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Event : Codable {
    let elapsed : Int
    let team_id : Int
    let teamName : String
    let player_id : Int
    let player : String
    let type : String
    let detail : String
}
