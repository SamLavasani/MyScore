//
//  ViewController.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire

class CompetitionsVC: UIViewController {
    
    
    @IBOutlet weak var competitionsTableView: UITableView!
    
    let filter = "?plan=TIER_ONE"
    
    var allCompetitions : [Competition] = []
    var sectionAreas : [String] = []
    var following : [Competition] = []

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
        competitionsTableView.reloadData()
        if Storage.fileExists("MyCompetitions", in: .documents) {
            // we have messages to retrieve
            following = Storage.retrieve("MyCompetitions", from: .documents, as: [Competition].self)
        }
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
        cell.followButton.isSelected = CompetitionHelper.isUserFollowingCompetition(comp: competition)
        let followImage = CompetitionHelper.isUserFollowingCompetition(comp: competition) ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
        cell.followButton.imageView?.image = followImage
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCompDetails", sender: self)
        
    }
}

//MARK: Delegates

extension CompetitionsVC: FollowCompetitionDelegate {
    
    func didTapFollowButton(comp: Competition) {
        if(CompetitionHelper.isUserFollowingCompetition(comp: comp)) {
           CompetitionHelper.unfollowCompetition(comp: comp)
        } else {
            following.append(comp)
            Storage.store(following, to: .documents, as: "MyCompetitions")
        }
    }
    
}

