//
//  ViewController.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire

class CompetitionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var competitionsTableView: UITableView!
    
    let COMPETITIONS_URL = "https://api.football-data.org/v2/competitions?plan=TIER_ONE"
    
    var myTeams : [Team] = []
    var currentUser = User()
    var allCompetitions : [Competition] = []
    var sectionAreas : [String] = []
    var areaCompetitions : [Competition] = []
    var user = User()
    let FOOTBALL_URL = "https://api.football-data.org/v2/competitions/2021/teams"
    let APP_ID = "b6e36c33acfe4c63a3ad11b761e1b7c4"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        competitionsTableView.delegate = self
        competitionsTableView.dataSource = self
        competitionsTableView.separatorStyle = .none
        competitionsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "MyCell")
        getAllCompetitions()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func getCompetitionsAreas() {
        sectionAreas.removeAll()
        for country in allCompetitions {
            let countryName = country.area.name
            if(!sectionAreas.contains(countryName)) {
                sectionAreas.append(countryName)
            }
        }
    }
    
    func getAllCompetitions() {
        let tokenHeader = HTTPHeader(name: "X-Auth-Token", value: APP_ID)
        let headers = HTTPHeaders([tokenHeader])
        AF.request(COMPETITIONS_URL, method: .get, parameters: [:], headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    let competitionData = try JSONDecoder().decode(CompetitionsResponse.self, from: data)
                    self.allCompetitions = competitionData.competitions
                    self.getCompetitionsAreas()
                    self.competitionsTableView.reloadData()
                } catch {
                    print(error)
                }
            case .failure(let error):
                print("No bueno \(error.localizedDescription)")
            }
        }
    }
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CompetitionDetailsVC
        if let indexPath = competitionsTableView.indexPathForSelectedRow {
            let sectionCompetitions = getCompetitionsInSection(section: indexPath.section)
            let competition = sectionCompetitions[indexPath.row]
            destinationVC.selectedCompetition = competition
        }
    }
    
    func isUserFollowingCompetition(comp: Competition) -> Bool {
        for competitions in user.following.competitions {
            if (competitions.id == comp.id) {
                return true
            }
        }
        return false
    }
    
    func getCompetitionsInSection(section: Int) -> [Competition] {
        let sectionArea = sectionAreas[section]
        let sectionCompetitions = allCompetitions.filter({ return $0.area.name == sectionArea})
        return sectionCompetitions
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func unfollowCompetition(comp: Competition) {
        user.following.competitions.removeAll { (competition) -> Bool in
            competition.id == comp.id
        }
    }

}

extension CompetitionsVC: FollowCellDelegate {
    
    func didTapFollowButton(comp: Competition) {
        if(isUserFollowingCompetition(comp: comp)) {
            unfollowCompetition(comp: comp)
        } else {
            user.following.competitions.append(comp)
        }
    }
    
}

