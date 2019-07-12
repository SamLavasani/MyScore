//
//  CountriesResponse.swift
//  MyScore
//
//  Created by Samuel on 2019-07-09.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

struct Countries : Codable {
    let results : Int
    let countries : [Country]
}

struct CountriesResponse : Codable {
    let api : Countries
}
