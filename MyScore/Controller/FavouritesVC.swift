//
//  FavouritesVC.swift
//  MyScore
//
//  Created by Samuel on 2019-06-03.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire

class FavouritesVC: UIViewController {
    
    private enum State {
        case teams
        case leagues
    }
    
    let filter = "?plan=TIER_ONE"
    @IBOutlet weak var fixtureTable: UITableView!
    @IBOutlet weak var leaguesButton: UIButton!
    @IBOutlet weak var teamsButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var followingTable: UITableView!
    
    var favouriteCompetitions : [Competition] = [] {
        didSet {
            Storage.store(favouriteCompetitions, to: .documents, as: .competition)
        }
    }
    var favouriteTeams : [Team] = [] {
        didSet {
            Storage.store(favouriteTeams, to: .documents, as: .team)
        }
    }
    var favouriteFixtures : [Match] = [] {
        didSet {
            Storage.store(favouriteFixtures, to: .documents, as: .fixtures)
        }
    }
    var shapeLayer = CAShapeLayer()
    let cellId = "MyCell"
    let fixtureCellId = "SmallFixtureCell"
    private var state : State = .teams
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followingTable.delegate = self
        followingTable.dataSource = self
        fixtureTable.delegate = self
        fixtureTable.dataSource = self
        fixtureTable.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
        followingTable.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Storage.fileExists(.competition, in: .documents) {
            favouriteCompetitions = Storage.retrieve(.competition, from: .documents, as: [Competition].self)
        }
        if Storage.fileExists(.team, in: .documents) {
            favouriteTeams = Storage.retrieve(.team, from: .documents, as: [Team].self)
        }
        if Storage.fileExists(.fixtures, in: .documents) {
            favouriteFixtures = Storage.retrieve(.fixtures, from: .documents, as: [Match].self)
        }
        followingTable.reloadData()
        fixtureTable.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        setupUnderLine()
    }
    
    fileprivate func setupUnderLine() {
        let frame: CGRect = buttonStackView.frame
        let y = frame.origin.y + teamsButton.frame.height
        
        let underLine = UIBezierPath()
        underLine.move(to: CGPoint(x: 0, y: y))
        underLine.addLine(to: CGPoint(x: frame.width, y: y))
        let underLineLayer = CAShapeLayer()
        underLineLayer.path = underLine.cgPath
        let color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        underLineLayer.strokeColor = color.cgColor
        underLineLayer.lineWidth = 1
        
        view.layer.addSublayer(underLineLayer)
        
        let selectedLine = UIBezierPath()
        selectedLine.move(to: CGPoint(x: 0, y: y))
        selectedLine.addLine(to: CGPoint(x: teamsButton.frame.width, y: y))
        
        shapeLayer.path = selectedLine.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        
        view.layer.addSublayer(shapeLayer)
    }
    
    
    @IBAction func teamsPressed(_ sender: UIButton) {
        sender.isSelected = true
        state = .teams
        leaguesButton.isSelected = false
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.followingTable.reloadData()
    }
    
    @IBAction func leaguesPressed(_ sender: UIButton) {
        sender.isSelected = true
        state = .leagues
        teamsButton.isSelected = false
        let x = teamsButton.frame.width + 10
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: x, y: 0, width: 0, height: 0)
        }
        self.followingTable.reloadData()
    }
}

extension FavouritesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == fixtureTable {
            return 85
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == followingTable {
            switch state {
            case .teams:
                return self.favouriteTeams.count
            case .leagues:
                return self.favouriteCompetitions.count
            }
        } else {
            return favouriteFixtures.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == followingTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
            switch state {
            case .teams:
                let team = favouriteTeams[indexPath.row]
                cell.mainLabel.text = team.name
                cell.setTeam(team: team)
                return cell
            case .leagues:
                let competition = favouriteCompetitions[indexPath.row]
                let isFollowing = FollowHelper.isFollowing(type: .competition, object: competition)
                cell.setCompetition(comp: competition)
                cell.delegate = self
                cell.mainLabel.text = competition.name
                cell.followButton.isSelected = isFollowing
                let followImage = isFollowing ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
                cell.followButton.imageView?.image = followImage
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
            let fixture = favouriteFixtures[indexPath.row]
            cell.homeTeamLabel.text = fixture.homeTeam.name
            cell.awayTeamLabel.text = fixture.awayTeam.name
            cell.setFixture(fixture: fixture)
            cell.delegate = self
            let dateInfo = DateHelper.getDateFromString(date: fixture.utcDate)
            cell.dateLabel.text = dateInfo.date
            if let minute = fixture.minute {
                cell.timeLabel.text = "\(minute)"
            } else {
                cell.timeLabel.text = dateInfo.time
            }
            cell.followButton.isSelected = FollowHelper.isFollowing(type: .fixtures, object: fixture)
            
            return cell
        }
    }
}

extension FavouritesVC: FollowDelegate {
    
    func didTapFollowButton<T>(object: T, type: Type) {
        let following = FollowHelper.isFollowing(type: type, object: object)

        if(following) {
            switch type {
            case .competition:
                let comp = object as! Competition
                favouriteCompetitions.removeAll { (competition) -> Bool in
                    competition.id == comp.id
                }
            case .team:
                let team = object as! Team
                favouriteTeams.removeAll { (teams) -> Bool in
                    teams.id == team.id
                }
            case .fixtures:
                let match = object as! Match
                favouriteFixtures.removeAll { (fixture) -> Bool in
                    fixture.id == match.id
                }
            }
        }
        else {
            switch type {
            case .competition:
                let comp = object as! Competition
                favouriteCompetitions.append(comp)
            case .team:
                let team = object as! Team
                favouriteTeams.append(team)
            case .fixtures:
                let match = object as! Match
                favouriteFixtures.append(match)
            }
        }
    }
    
}
