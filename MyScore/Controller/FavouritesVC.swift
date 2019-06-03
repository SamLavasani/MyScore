//
//  FavouritesVC.swift
//  MyScore
//
//  Created by Samuel on 2019-06-03.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import CoreData

class FavouritesVC: UIViewController {
    var favouriteCompetitions : [Competition] = []
    var favouriteTeams : [Team] = []
    var favouriteFixtures : [Matches] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let match = favouriteFixtures[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SmallFixtureCell", for: indexPath) as! SmallFixtureTableViewCell
        let dateInfo = getDateFromString(date: match.utcDate)
        cell.homeTeamLabel.text = match.homeTeam.name
        cell.awayTeamLabel.text = match.awayTeam.name
        cell.dateLabel.text = dateInfo.date
        cell.timeLabel.text = dateInfo.time
        cell.homeTeamScore.isHidden = match.status != "LIVE"
        cell.awayTeamScore.isHidden = match.status != "LIVE"
        return cell
    }
    
    
}
