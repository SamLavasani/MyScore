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
            case .leagues:
                let competition = object as! League
                let follows = Storage.retrieve(.leagues, from: .documents, as: [League].self)
                for competitions in follows {
                    if (competitions.league_id == competition.league_id) {
                        return true
                    }
                }
                return false
            case .team:
                let team = object as! Team
                let follows = Storage.retrieve(.team, from: .documents, as: [Team].self)
                for teams in follows {
                    if (teams.team_id == team.team_id) {
                        return true
                    }
                }
                return false
            case .fixtures:
                let fixture = object as! Fixture
                let follows = Storage.retrieve(.fixtures, from: .documents, as: [Fixture].self)
                for match in follows {
                    if (match.fixture_id == fixture.fixture_id) {
                        return true
                    }
                }
                return false
            }
            
        } else { return false }
        
    }
    
}
