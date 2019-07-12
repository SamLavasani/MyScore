//
//  StandingsResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-10.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Standings : Codable {
    let results : Int?
    let standings : [[Standing]]
}

struct StandingsResponse : Codable {
    let api : Standings
}
