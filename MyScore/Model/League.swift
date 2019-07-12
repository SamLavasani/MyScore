//
//  League.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct League : Codable {
    let league_id : Int
    let name : String
    let country : String
    let country_code : String?
    let season : Int
    let season_start : String
    let season_end : String
    let logo : String?
    let flag : String?
    let standings : Int
    let is_current : Int
}
