//
//  ViewController.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class CompetitionsVC: UIViewController {
    
    
    @IBOutlet weak var competitionsTableView: UITableView!
    
    let COMPETITIONS_URL = "https://api.football-data.org/v2/competitions"
    let filter = "?plan=TIER_ONE"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var allCompetitions : [Competition] = []
    var sectionAreas : [String] = []
    var following : [CoreCompetition] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTable()
        getAllCompetitions()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        //fetchFromCoreData()
        following = CoreDataHelper.fetchCompetitionsFromCoreData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupTable() {
        competitionsTableView.delegate = self
        competitionsTableView.dataSource = self
        competitionsTableView.separatorStyle = .none
        competitionsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCell")
    }
    
    func isUserFollowingCompetition(comp: Competition) -> Bool {
        for competitions in following {
            if (competitions.id == comp.id) {
                return true
            }
        }
        return false
    }
    
    //MARK: Core Data
    func fetchFromCoreData() {
        let fetchRequest : NSFetchRequest = CoreCompetition.fetchRequest()
        
        do {
            following = try context.fetch(fetchRequest)
            //print("Fetch Following \(following)")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveToCoreData(comp: Competition) {
        let competition = CoreCompetition(context: context)
        
        competition.id = Int32(comp.id)
        competition.title = comp.name
        
        do {
            try context.save()
            following.append(competition)
            print(self.following)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteFromCoreData(id: Int) {
        let request : NSFetchRequest = CoreCompetition.fetchRequest()
        request.predicate = NSPredicate(format: "id == \(id)")
        do {
            let comp = try context.fetch(request)
            
            if let competition = comp.first {
                // we've got the profile already cached!
                context.delete(competition)
                try context.save()
                print(self.following)
            }
        } catch let error as NSError {
            // handle error
            print("Could not remove. \(error), \(error.userInfo)")
        }
    }
    
    //Mark: Competition request
    func getAllCompetitions() {
        guard let url = URL(string: MyScoreURL.competitions + filter) else { return }
        APIManager.shared.apiRequest(url: url, onSuccess: { [weak self] (data) in
            do {
                let competitionData = try JSONDecoder().decode(CompetitionsResponse.self, from: data)
                self?.allCompetitions = competitionData.competitions
                self?.getCompetitionsAreas()
                self?.competitionsTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func getCompetitionsAreas() {
        sectionAreas.removeAll()
        for country in allCompetitions {
            let countryName = country.area?.name
            if(!sectionAreas.contains(countryName!)) {
                sectionAreas.append(countryName!)
            }
        }
    }
    
    func getCompetitionsInSection(section: Int) -> [Competition] {
        let sectionArea = sectionAreas[section]
        let sectionCompetitions = allCompetitions.filter({ return $0.area?.name == sectionArea})
        return sectionCompetitions
    }
    
    func unfollowCompetition(comp: Competition) {
        following.removeAll { (competition) -> Bool in
            competition.id == comp.id
        }
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CompetitionDetailsVC
        if let indexPath = competitionsTableView.indexPathForSelectedRow {
            let sectionCompetitions = getCompetitionsInSection(section: indexPath.section)
            let competition = sectionCompetitions[indexPath.row]
            destinationVC.selectedCompetition = competition
        }
    }

}

//MARK: Tableview datasource and delegate

extension CompetitionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionAreas.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAreas[section]
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCompetitions = getCompetitionsInSection(section: section)
        return sectionCompetitions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionCompetitions = getCompetitionsInSection(section: indexPath.section)
        let competition = sectionCompetitions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! CustomTableViewCell
        cell.setCompetition(comp: competition)
        cell.delegate = self
        cell.mainLabel.text = competition.name
        cell.followButton.isSelected = isUserFollowingCompetition(comp: competition)
        let followImage = isUserFollowingCompetition(comp: competition) ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
        cell.followButton.imageView?.image = followImage
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCompDetails", sender: self)
        
    }
}

//MARK: Delegates

extension CompetitionsVC: FollowCellDelegate {
    
    func didTapFollowButton(comp: Competition) {
        if(isUserFollowingCompetition(comp: comp)) {
            unfollowCompetition(comp: comp)
            //deleteFromCoreData(id: comp.id)
            CoreDataHelper.deleteFromCoreData(id: comp.id)
        } else {
            //saveToCoreData(comp: comp)
            CoreDataHelper.saveCompetitionToCoreData(comp: comp)
            following = CoreDataHelper.fetchCompetitionsFromCoreData()
        }
    }
    
}

