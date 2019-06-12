//
//  CoreDataHelper.swift
//  MyScore
//
//  Created by Samuel on 2019-06-12.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static func fetchCompetitionsFromCoreData() -> [CoreCompetition] {
        let fetchRequest : NSFetchRequest = CoreCompetition.fetchRequest()
        do {
            let following = try context.fetch(fetchRequest)
            return following
            //print("Fetch Following \(following)")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return []
    }
    
    static func saveCompetitionToCoreData(comp: Competition) {
        let competition = CoreCompetition(context: context)
        
        competition.id = Int32(comp.id)
        competition.title = comp.name
        
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    static func deleteFromCoreData(id: Int) {
        let request : NSFetchRequest = CoreCompetition.fetchRequest()
        request.predicate = NSPredicate(format: "id == \(id)")
        do {
            let comp = try context.fetch(request)
            
            if let competition = comp.first {
                // we've got the profile already cached!
                context.delete(competition)
                try context.save()
            }
        } catch let error as NSError {
            // handle error
            print("Could not remove. \(error), \(error.userInfo)")
        }
    }
}
