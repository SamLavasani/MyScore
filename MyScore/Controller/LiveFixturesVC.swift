//
//  LiveFixturesVC.swift
//  MyScore
//
//  Created by Samuel on 2019-07-22.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class LiveFixturesVC: UIViewController {
    let fixtureCellId = "SmallFixtureCell"
    var liveFixtures : [Fixture] = []

    @IBOutlet weak var fixtureTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fixtureTableView.delegate = self
        fixtureTableView.dataSource = self
        fixtureTableView.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
    }
}

extension LiveFixturesVC: FollowDelegate {
    func didTapFollowButton<T>(object: T, type: Type) {
        
    }
    
    
}

extension LiveFixturesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return liveFixtures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
        let fixture = liveFixtures[indexPath.row]
        cell.homeTeamLabel.text = fixture.homeTeam.team_name
        cell.awayTeamLabel.text = fixture.awayTeam.team_name
        cell.setFixture(fixture: fixture)
        cell.delegate = self
        let dateInfo = DateHelper.getDateFromString(date: fixture.event_date)
        cell.dateLabel.text = dateInfo.date
        if let minute = fixture.elapsed {
            cell.timeLabel.text = "\(minute)"
        } else {
            cell.timeLabel.text = dateInfo.time
        }
        if let homeGoals = fixture.goalsHomeTeam {
            cell.homeTeamScore.text = "\(homeGoals)"
        } else {
            cell.homeTeamScore.text = ""
        }
        if let awayGoals = fixture.goalsHomeTeam {
            cell.awayTeamScore.text = "\(awayGoals)"
        } else {
            cell.awayTeamScore.text = ""
        }
        cell.followButton.isSelected = FollowHelper.isFollowing(type: .fixtures, id: fixture.fixture_id)
        return cell
    }
    
    
}
