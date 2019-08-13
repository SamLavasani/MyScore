//
//  LineUp.swift
//  MyScore
//
//  Created by Samuel on 2019-08-13.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation
struct LineUp : Codable {
    let formation : String
    let startXI : [LineUpPlayer]
    let substitutes : [LineUpPlayer]
    
}
