//
//  CompetitionDetailsVC.swift
//  MyScore
//
//  Created by Samuel on 2019-05-21.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire

class CompetitionDetailsVC: UIViewController {
    private enum State {
        case fixtures
        case table
    }
    
    var selectedLeague : League?
    let leagueCellId = "LeagueTableCell"
    let fixtureCellId = "SmallFixtureCell"
    var path = UIBezierPath()
    
    @IBOutlet weak var competitionLabel: UILabel!
    
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var tableButton: UIButton!
    @IBOutlet weak var fixtureButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    var shapeLayer = CAShapeLayer()
    private var state : State = .fixtures
    
    var allFixtures : [Fixture] = []
    //var teamPositions : [TeamPosition] = []
    var standings : [Standing] = []
    var favouriteFixtures : [Fixture] = [] {
        didSet {
            Storage.store(favouriteFixtures, to: .documents, as: .fixtures)
        }
    }
    var favouriteTeams : [Team] = [] {
        didSet {
            Storage.store(favouriteTeams, to: .documents, as: .team)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionTableView.delegate = self
        competitionTableView.dataSource = self
        competitionTableView.separatorStyle = .none
        competitionLabel.text = selectedLeague?.name
        competitionTableView.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
        competitionTableView.register(UINib(nibName: "LeagueTableViewCell", bundle: nil), forCellReuseIdentifier: leagueCellId)
        if Storage.fileExists(.fixtures, in: .documents) {
         favouriteFixtures = Storage.retrieve(.fixtures, from: .documents, as: [Fixture].self)
        }
        if Storage.fileExists(.team, in: .documents) {
            favouriteTeams = Storage.retrieve(.team, from: .documents, as: [Team].self)
        }
        getLeagueFixtures()
        getStandingsInLeague()
        setupTransparentNavBar()
    }
    
    func setupTransparentNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
    
    fileprivate func setupUnderLine() {
        let frame: CGRect = buttonStackView.frame
        let y = frame.origin.y + fixtureButton.frame.height
        
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
        selectedLine.addLine(to: CGPoint(x: fixtureButton.frame.width, y: y))
        
        shapeLayer.path = selectedLine.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 3
        
        view.layer.addSublayer(shapeLayer)
    }
    
    override func viewDidLayoutSubviews() {
        setupUnderLine()
    }
    
    @IBAction func fixturePressed(_ sender: UIButton) {
        state = .fixtures
        if !sender.isSelected {
            slideAnimationForTable()
        }
        sender.isSelected = true
        tableButton.isSelected = false
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        competitionTableView.reloadData()
    }
    
    @IBAction func tablePressed(_ sender: UIButton) {
        state = .table
        if !sender.isSelected {
            slideAnimationForTable()
        }
        sender.isSelected = true
        fixtureButton.isSelected = false
        let x = fixtureButton.frame.width + 10
        
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: x, y: 0, width: 0, height: 0)
        }
        competitionTableView.reloadData()
    }
    
    func slideAnimationForTable() {
        let tx : CGFloat = state == .fixtures ? -500 : 500
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, tx, 0, 0)
        competitionTableView.layer.transform = rotationTransform
        UIView.animate(withDuration: 0.35) {
            self.competitionTableView.layer.transform = CATransform3DIdentity
        }
    }
    
    func getLeagueFixtures() {
        guard let leagueID = selectedLeague?.league_id else { return }
        let filter = "/league/\(leagueID)"
        guard let url = URL(string: MyScoreURL.fixtures + filter) else { return }
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let fixtureData = try JSONDecoder().decode(FixturesResponse.self, from: data)
                self?.allFixtures = fixtureData.api.fixtures
                self?.competitionTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func getStandingsInLeague() {
        guard let leagueID = selectedLeague?.league_id else { return }
        guard let url = URL(string: "\(MyScoreURL.leagueTable)\(leagueID)") else { return }
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let standingsData = try JSONDecoder().decode(StandingsResponse.self, from: data)
                guard let tableStandings = standingsData.api.standings.first else { return }
                self?.standings = tableStandings
                self?.competitionTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
}

extension CompetitionDetailsVC: FollowDelegate {
    func didTapFollowButton<T>(object: T, type: Type) {
        let following = FollowHelper.isFollowing(type: type, id:: object)
        
        if type == .team {
            let team = object as! Team
            if(following) {
                favouriteTeams.removeAll { (teams) -> Bool in
                    teams.team_id == team.team_id
                }
            } else {
                favouriteTeams.append(team)
            }
            
        } else {
            let fixture = object as! Fixture
            if(following) {
                favouriteFixtures.removeAll { (match) -> Bool in
                    match.fixture_id == fixture.fixture_id
                }
            } else {
                favouriteFixtures.append(fixture)
            }
            
        }
    }
    
    
}

extension CompetitionDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .fixtures:
            return allFixtures.count
        case .table:
            return standings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .fixtures:
            let match = allFixtures[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
            let dateInfo = DateHelper.getDateFromString(date: match.event_date)
            cell.delegate = self
            cell.homeTeamLabel.text = match.homeTeam.team_name
            cell.awayTeamLabel.text = match.awayTeam.team_name
            cell.dateLabel.text = dateInfo.date
            cell.timeLabel.text = dateInfo.time
            cell.homeTeamScore.isHidden = match.status != "LIVE"
            cell.awayTeamScore.isHidden = match.status != "LIVE"
            cell.followButton.isSelected = FollowHelper.isFollowing(type: .fixtures, id:: match)
            cell.setFixture(fixture: match)
            return cell
        case .table:
            let standing = standings[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: leagueCellId, for: indexPath) as! LeagueTableViewCell
            cell.delegate = self
            cell.teamNameLabel.text = standing.teamName
            cell.gamesPlayedLabel.text = "P: \(standing.all?.matchsPlayed ?? 0)"
            cell.goalDifferenceLabel.text = "GD: \(standing.goalsDiff)"
            cell.teamPosition.text = "#\(standing.rank)"
            cell.pointsLabel.text = "PTS: \(standing.points)"
            cell.followButton.isSelected = FollowHelper.isFollowing(type: .team, id:: standing.team_id)
            //cell.setTeam(team: position.team)
            return cell
        }
    }
    
    
}
