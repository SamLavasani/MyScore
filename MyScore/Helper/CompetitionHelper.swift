//
//  CompetitionHelper.swift
//  MyScore
//
//  Created by Samuel on 2019-06-12.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class CompetitionHelper {
    
    static func isUserFollowingCompetition(comp: Competition) -> Bool {
        var following : [Competition] = []
        if Storage.fileExists("MyCompetitions", in: .documents) {
            // we have messages to retrieve
            following = Storage.retrieve("MyCompetitions", from: .documents, as: [Competition].self)
        }
        for competitions in following {
            if (competitions.id == comp.id) {
                return true
            }
        }
        return false
    }
    
    static func unfollowCompetition(comp: Competition) {
        var following : [Competition] = []
        if Storage.fileExists("MyCompetitions", in: .documents) {
            // we have messages to retrieve
            following = Storage.retrieve("MyCompetitions", from: .documents, as: [Competition].self)
        }
        following.removeAll { (competition) -> Bool in
            competition.id == comp.id
        }
        Storage.store(following, to: .documents, as: "MyCompetitions")
    }
}
