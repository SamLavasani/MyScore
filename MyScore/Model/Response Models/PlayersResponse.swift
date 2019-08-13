//
//  PlayersResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-29.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation

struct Players : Codable {
    let results : Int?
    let players : [Player]
}

struct PlayersResponse : Codable {
    let api : Players
}
