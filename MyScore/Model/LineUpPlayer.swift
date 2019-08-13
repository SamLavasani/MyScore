//
//  Player.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct LineUpPlayer : Codable {
    let team_id : Int
    let player_id : Int
    let player : String
    let number : Int
    let pos : String
}
