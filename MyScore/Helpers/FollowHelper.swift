//
//  FollowHelper.swift
//  MyScore
//
//  Created by Samuel on 2019-06-17.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation

struct FollowHelper {
     static func isFollowing<T>(type: Type, object: T) -> Bool {
        
        if Storage.fileExists(type, in: .documents) {
            switch type {
            case .competition:
                let competition = object as! Competition
                let follows = Storage.retrieve(.competition, from: .documents, as: [Competition].self)
                for competitions in follows {
                    if (competitions.id == competition.id) {
                        return true
                    }
                }
                return false
            case .team:
                let team = object as! Team
                let follows = Storage.retrieve(.team, from: .documents, as: [Team].self)
                for teams in follows {
                    if (teams.id == team.id) {
                        return true
                    }
                }
                return false
            case .fixtures:
                let fixture = object as! Match
                let follows = Storage.retrieve(.fixtures, from: .documents, as: [Match].self)
                for match in follows {
                    if (match.id == fixture.id) {
                        return true
                    }
                }
                return false
            }
            
        } else { return false }
        
    }
    
}
