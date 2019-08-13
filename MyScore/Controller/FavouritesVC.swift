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
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var followedLeagues : [League] = [] {
        didSet {
            Storage.store(followedLeagues, to: .documents, as: .leagues)
        }
    }
    var followedTeams : [Team] = [] {
        didSet {
            Storage.store(followedTeams, to: .documents, as: .team)
        }
    }
    var storedFixtures : [FixtureStorage] = [] {
        didSet {
            Storage.store(storedFixtures, to: .documents, as: .fixtures)
        }
    }
    var followedFixtures : [Fixture] = []
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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if Storage.fileExists(.leagues, in: .documents) {
            followedLeagues = Storage.retrieve(.leagues, from: .documents, as: [League].self)
        }
        if Storage.fileExists(.team, in: .documents) {
            followedTeams = Storage.retrieve(.team, from: .documents, as: [Team].self)
        }
        if Storage.fileExists(.fixtures, in: .documents) {
            storedFixtures = Storage.retrieve(.fixtures, from: .documents, as: [FixtureStorage].self)
            followedFixtures = []
            getSavedFixtures()
        }
        followingTable.reloadData()
        fixtureTable.reloadData()
        slideAnimationForFixture()
        slideAnimationForTable()
    }
    
    override func viewDidLayoutSubviews() {
        setupUnderLine()
    }
    
    func getSavedFixtures() {
        let fixtureGroup = DispatchGroup()
        for (pos, localFixture) in storedFixtures.enumerated() {
            fixtureGroup.enter()
            let id = localFixture.id
            guard let url = URL(string: MyScoreURL.fixture + "\(id)") else { return }
            APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
                do {
                    let fixtureData = try JSONDecoder().decode(FixturesResponse.self, from: data)
                    guard let fixture = fixtureData.api.fixtures.first else { return }
                    self?.followedFixtures.append(fixture)
                    print("Finished request \(pos)")
                    fixtureGroup.leave()
                } catch {
                    print(error)
                }
            }) { (error) in
                print(error)
            }
        }
        fixtureGroup.notify(queue: .main) {
            self.fixtureTable.reloadData()
            self.slideAnimationForFixture()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func slideAnimationForTable() {
        let tx : CGFloat = state == .teams ? -500 : 500
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, tx, 0, 0)
        followingTable.layer.transform = rotationTransform
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.followingTable.layer.transform = CATransform3DIdentity
        })
    }
    
    func slideAnimationForFixture() {
        let ty : CGFloat = 500
        let cells = fixtureTable.visibleCells
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, ty, 0)
        for cell in cells {
            cell.layer.transform = rotationTransform
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                cell.layer.transform = CATransform3DIdentity
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToCompDetails") {
            let destinationVC = segue.destination as! CompetitionDetailsVC
            if let indexPath = followingTable.indexPathForSelectedRow {
                let league = followedLeagues[indexPath.row]
                destinationVC.selectedLeague.league = league
            }
        } else if (segue.identifier == "goToTeamDetails") {
            let destinationVC = segue.destination as! TeamDetailsVC
            if let indexPath = followingTable.indexPathForSelectedRow {
                let team = followedTeams[indexPath.row]
                destinationVC.teamID = team.team_id
            }
        } else if (segue.identifier == "goToFixtureDetails") {
            let destinationVC = segue.destination as! FixtureDetailsVC
            if let indexPath = fixtureTable.indexPathForSelectedRow {
                let fixture = followedFixtures[indexPath.row]
                destinationVC.fixtureID = fixture.fixture_id
            }
        }
    }
    
    
    @IBAction func teamsPressed(_ sender: UIButton) {
        state = .teams
        if !sender.isSelected {
            slideAnimationForTable()
        }
        sender.isSelected = true
        leaguesButton.isSelected = false
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.followingTable.reloadData()
    }
    
    @IBAction func leaguesPressed(_ sender: UIButton) {
        state = .leagues
        if !sender.isSelected {
            slideAnimationForTable()
        }
        sender.isSelected = true
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
                return self.followedTeams.count
            case .leagues:
                return self.followedLeagues.count
            }
        } else {
            return followedFixtures.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == fixtureTable {
            performSegue(withIdentifier: "goToFixtureDetails", sender: self)
        } else {
            switch state {
            case .leagues:
                performSegue(withIdentifier: "goToCompDetails", sender: self)
            case .teams:
                performSegue(withIdentifier: "goToTeamDetails", sender: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == followingTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
            switch state {
            case .teams:
                let team = followedTeams[indexPath.row]
                let isFollowing = FollowHelper.isFollowing(type: .team, id: team.team_id)
                cell.mainLabel.text = team.name
                let followImage = isFollowing ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
                cell.followButton.imageView?.image = followImage
                //cell.setTeam(team: team)
                return cell
            case .leagues:
                let competition = followedLeagues[indexPath.row]
                let isFollowing = FollowHelper.isFollowing(type: .leagues, id: competition.league_id)
                //cell.setLeague(league: competition)
                cell.delegate = self
                cell.mainLabel.text = competition.name
                cell.followButton.isSelected = isFollowing
                let followImage = isFollowing ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
                cell.followButton.imageView?.image = followImage
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
            let fixture = followedFixtures[indexPath.row]
            cell.homeTeamLabel.text = fixture.homeTeam.team_name
            cell.awayTeamLabel.text = fixture.awayTeam.team_name
            cell.setFixture(fixture: fixture)
            cell.delegate = self
            let dateInfo = DateHelper.getDateFromString(date: fixture.event_date)
            cell.dateLabel.text = dateInfo.date
            if fixture.status != "LIVE" {
                if fixture.status == "Not Started"{
                    cell.timeLabel.text = dateInfo.time
                } else {
                    cell.timeLabel.text = fixture.statusShort
                }
            } else {
                if let minute = fixture.elapsed {
                    cell.timeLabel.text = "\(minute)'"
                } else {
                    cell.timeLabel.text = dateInfo.time
                }
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
}

extension FavouritesVC: FollowDelegate {
    
    func didTapFollowButton<T>(object: T, type: Type) {
        
        switch type {
        case .leagues:
            let league = object as! League
            let following = FollowHelper.isFollowing(type: type, id: league.league_id)
            if(following) {
                followedLeagues.removeAll { (leagues) -> Bool in
                    leagues.league_id == league.league_id
                }} else {
                followedLeagues.append(league)
            }
            
        case .team:
            let team = object as! Team
            let following = FollowHelper.isFollowing(type: type, id: team.team_id)
            if(following) {
                followedTeams.removeAll { (teams) -> Bool in
                    teams.team_id == team.team_id
                }} else {
                followedTeams.append(team)
            }
        case .fixtures:
            let match = object as! Fixture
            let following = FollowHelper.isFollowing(type: type, id: match.fixture_id)
            if(following) {
                storedFixtures.removeAll { (fixtures) -> Bool in
                    fixtures.id == match.fixture_id
                }} else {
                let fixtureStorage = FixtureStorage(id: match.fixture_id)
                storedFixtures.append(fixtureStorage)
            }
        }
        followingTable.reloadData()
        fixtureTable.reloadData()
    }
    
}
