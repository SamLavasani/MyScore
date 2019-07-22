//
//  FollowHelper.swift
//  MyScore
//
//  Created by Samuel on 2019-06-17.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import Foundation

struct FollowHelper {
     static func isFollowing(type: Type, id: Int) -> Bool {
        
        if Storage.fileExists(type, in: .documents) {
            switch type {
            case .leagues:
                let following = Storage.retrieve(.leagues, from: .documents, as: [League].self)
                for leagues in following {
                    if (leagues.league_id == id) {
                        return true
                    }
                }
                return false
            case .team:
                let following = Storage.retrieve(.team, from: .documents, as: [Team].self)
                for teams in following {
                    if (teams.team_id == id) {
                        return true
                    }
                }
                return false
            case .fixtures:
                let following = Storage.retrieve(.fixtures, from: .documents, as: [FixtureStorage].self)
                for match in following {
                    if (match.id == id) {
                        return true
                    }
                }
                return false
            }
            
        } else { return false }
        
    }
    
}
