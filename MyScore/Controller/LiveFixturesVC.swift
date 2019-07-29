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
    var favouriteFixtures : [FixtureStorage] = [] {
        didSet {
            Storage.store(favouriteFixtures, to: .documents, as: .fixtures)
        }
    }

    @IBOutlet weak var fixtureTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fixtureTableView.delegate = self
        fixtureTableView.dataSource = self
        fixtureTableView.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Storage.fileExists(.fixtures, in: .documents) {
            favouriteFixtures = Storage.retrieve(.fixtures, from: .documents, as: [FixtureStorage].self)
        }
        getLiveFixtures()
    }
    
    func getLiveFixtures() {
        guard let url = URL(string: MyScoreURL.liveFixtures) else { return }
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let fixtureData = try JSONDecoder().decode(FixturesResponse.self, from: data)
                self?.liveFixtures = fixtureData.api.fixtures
                self?.fixtureTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            
        }
    }
}

extension LiveFixturesVC: FollowDelegate {
    func didTapFollowButton<T>(object: T, type: Type) {
        let fixture = object as! Fixture
        let following = FollowHelper.isFollowing(type: type, id: fixture.fixture_id)
        if(following) {
            favouriteFixtures.removeAll { (match) -> Bool in
                match.id == fixture.fixture_id
            }
        } else {
            let fixtureStorage = FixtureStorage(id: fixture.fixture_id)
            favouriteFixtures.append(fixtureStorage)
        }
    }
    
    
}

extension LiveFixturesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
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
            cell.timeLabel.text = "\(minute)'"
        } else {
            cell.timeLabel.text = dateInfo.time
        }
        
        if let homeGoals = fixture.goalsHomeTeam {
            cell.homeTeamScore.text = "\(homeGoals)"
        } else {
            cell.homeTeamScore.text = ""
        }
        
        if let awayGoals = fixture.goalsAwayTeam {
            cell.awayTeamScore.text = "\(awayGoals)"
        } else {
            cell.awayTeamScore.text = ""
        }
        
        cell.followButton.isSelected = FollowHelper.isFollowing(type: .fixtures, id: fixture.fixture_id)
        return cell
    }
    
    
}
