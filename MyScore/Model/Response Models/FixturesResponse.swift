//
//  FixturesResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-10.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Fixtures : Codable {
    let results : Int
    let fixtures : [Fixture]
}

struct FixturesResponse : Codable {
    let api : Fixtures
}
