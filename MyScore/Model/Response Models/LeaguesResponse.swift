//
//  LeaguesResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Leagues : Codable {
    let results : Int
    let leagues : [League]
}

struct LeaguesResponse : Codable {
    let api : Leagues
}
