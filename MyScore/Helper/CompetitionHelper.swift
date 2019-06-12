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
        let following = CoreDataHelper.fetchCompetitionsFromCoreData()
        for competitions in following {
            if (competitions.id == comp.id) {
                return true
            }
        }
        return false
    }
}
