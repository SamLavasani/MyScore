//
//  TeamsResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-22.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Teams : Codable {
    let results : Int?
    let teams : [Team]
}

struct TeamsResponse : Codable {
    let api : Teams
}
