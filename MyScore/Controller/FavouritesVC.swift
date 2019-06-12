//
//  FavouritesVC.swift
//  MyScore
//
//  Created by Samuel on 2019-06-03.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

class FavouritesVC: UIViewController {
    @IBOutlet weak var fixtureTable: UITableView!
    
    @IBOutlet weak var followingTable: UITableView!
    let FIXTURE_URL = "https://api.football-data.org/v2/teams/{id}/matches?limit=1"
    let APP_ID = "b6e36c33acfe4c63a3ad11b761e1b7c4"
    var favouriteCompetitions : [CoreCompetition] = []
    var favouriteTeams : [CoreTeam] = []
    var favouriteFixtures : [Matches] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTeamsFromCoreData()
        fetchCompetitionsFromCoreData()
        
    }
    
    
    @IBAction func teamsPressed(_ sender: UIButton) {
    }
    
    @IBAction func leaguesPressed(_ sender: UIButton) {
    }
    
    func fetchCompetitionsFromCoreData() {
        let fetchRequest : NSFetchRequest = CoreCompetition.fetchRequest()
        
        do {
            favouriteCompetitions = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchTeamsFromCoreData() {
        let fetchRequest : NSFetchRequest = CoreTeam.fetchRequest()
        
        do {
            favouriteTeams = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func getAllCompetitions() {
        let tokenHeader = HTTPHeader(name: "X-Auth-Token", value: APP_ID)
        let headers = HTTPHeaders([tokenHeader])
        guard let id = favouriteTeams.first else { return }
        let url = FIXTURE_URL + "\(id)" + "/matches?limit=1"
        AF.request(url, method: .get, parameters: [:], headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    guard let data = response.data else { return }
                    //let competitionData = try JSONDecoder().decode(CompetitionsResponse.self, from: data)
//                    self.allCompetitions = competitionData.competitions
//                    self.getCompetitionsAreas()
//                    self.competitionsTableView.reloadData()
                    print(data)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print("No bueno \(error.localizedDescription)")
            }
        }
    }
    
    func getDateFromString(date: String) -> DateInfo {
        var dateInfo = DateInfo()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let newDate = formatter.date(from: date) {
            //print(date)
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM"
            let date = formatter.string(from: newDate)
            formatter.dateFormat = "HH:mm"
            let time = formatter.string(from: newDate)
            dateInfo.date = date
            dateInfo.time = time
        }
        return dateInfo
    }
}

extension FavouritesVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteTeams.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let team = favouriteTeams[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmallFixtureCell", for: indexPath) as! SmallFixtureTableViewCell
        //let dateInfo = getDateFromString(date: match.utcDate)
        cell.homeTeamLabel.text = team.name
        //cell.awayTeamLabel.text = match.awayTeam.name
//        cell.dateLabel.text = dateInfo.date
//        cell.timeLabel.text = dateInfo.time
//        cell.homeTeamScore.isHidden = match.status != "LIVE"
//        cell.awayTeamScore.isHidden = match.status != "LIVE"
        return cell
    }
    
    
}
