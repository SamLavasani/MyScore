//
//  TeamDetailsVC.swift
//  MyScore
//
//  Created by Samuel on 2019-07-03.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class TeamDetailsVC: UIViewController {
    
    var team : Team!
    
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var fixtureButton: UIButton!
    @IBOutlet weak var squadButton: UIButton!
    @IBOutlet weak var venueLabel: UILabel!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var teamTable: UITableView!
    
    var squad : [Player] = []
    var teamFixtures : [Fixture] = []
    var sectionPositions : [String] = []
    var shapeLayer = CAShapeLayer()
    var favouriteFixtures : [Fixture] = [] {
        didSet {
            Storage.store(favouriteFixtures, to: .documents, as: .fixtures)
        }
    }
    
    private enum State {
        case fixtures
        case squad
    }
    let fixtureCellId = "SmallFixtureCell"
    let cellId = "MyCell"
    
    private var state : State = .fixtures
    
    
    override func viewDidLoad() {
        teamLabel.text = team.name
        venueLabel.text = team.venue_name
        teamTable.delegate = self
        teamTable.dataSource = self
        teamTable.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
        teamTable.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        setupTransparentNavBar()
        setupUnderLine()
        if Storage.fileExists(.fixtures, in: .documents) {
            favouriteFixtures = Storage.retrieve(.fixtures, from: .documents, as: [Fixture].self)
        }
        getFixturesForTeam()
        getSquadFromTeam()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupTransparentNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
    
    func slideAnimationForFixture() {
        let ty : CGFloat = 500
        let cells = teamTable.visibleCells
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, ty, 0)
        for cell in cells {
            cell.layer.transform = rotationTransform
            UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                cell.layer.transform = CATransform3DIdentity
            })
        }
    }
    
    fileprivate func setupUnderLine() {
        let frame: CGRect = buttonStackView.frame
        let y = frame.origin.y + squadButton.frame.height
        
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
    
    func getSquadFromTeam() {
        let urlString = MyScoreURL.teams + "/\(team.team_id)"
        guard let url = URL(string: urlString) else { return }
        //print(url)
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let squadData = try JSONDecoder().decode(TeamDetailsResponse.self, from: data)
                self?.squad = squadData.squad
                self?.getSquadPostitions()
                self?.teamTable.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFixturesForTeam() {
        // http://api.football-data.org/v2/teams/759/matches
        //https://api.football-data.org/v2/teams/64/matches
        let filterMatches = "/matches?"
//        let dateFrom = "dateFrom="
//        let dateTo = "&dateTo="
//        let currentDate = DateHelper.getCurrentDate()
//        let endDate = "2019-09-30"
//        let filterDate = dateFrom + currentDate + dateTo + endDate
        let filter = filterMatches + "limit=10"
        let urlString = MyScoreURL.teams + "/" + "\(team.team_id)" + filter
        guard let url = URL(string: urlString) else { return }
        print(url)
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let fixtureData = try JSONDecoder().decode(MatchesResponse.self, from: data)
                //self?.teamFixtures = fixtureData.matches
                self?.teamTable.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getSquadPostitions() {
        sectionPositions.removeAll()
        for player in squad {
            let position = player.pos
            if(!sectionPositions.contains(position)) {
                sectionPositions.append(position)
            }
        }
        
    }
    
    func getPlayersInSection(section: Int) -> [Player] {
        let position = sectionPositions[section]
        let sectionsPlayers = squad.filter({ return $0.pos == position})
        return sectionsPlayers
    }
    
    @IBAction func fixtureButtonPressed(_ sender: UIButton) {
        sender.isSelected = true
        state = .fixtures
        squadButton.isSelected = false
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.teamTable.reloadData()
        slideAnimationForFixture()
    }
    @IBAction func squadButtonPressed(_ sender: UIButton) {
        sender.isSelected = true
        state = .squad
        fixtureButton.isSelected = false
        let x = squadButton.frame.width + 10
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: x, y: 0, width: 0, height: 0)
        }
        self.teamTable.reloadData()
        slideAnimationForFixture()
    }
    
}

extension TeamDetailsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch state {
        case .fixtures:
            return 0
        case .squad:
            return sectionPositions.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionPositions[section]
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .fixtures:
            return teamFixtures.count
        case .squad:
            let players = getPlayersInSection(section: section)
            return players.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .fixtures:
            let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
            let fixture = teamFixtures[indexPath.row]
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
            cell.followButton.isSelected = FollowHelper.isFollowing(type: .fixtures, id:: fixture)
            return cell
        case .squad:
            let cell = teamTable.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
            let playersInSection = getPlayersInSection(section: indexPath.section)
            let player = playersInSection[indexPath.row]
            cell.followButton.isHidden = true
            cell.mainLabel.text = player.player
            return cell
        }
    }
    
    
}

extension TeamDetailsVC: FollowDelegate {
    func didTapFollowButton<T>(object: T, type: Type) {
        let following = FollowHelper.isFollowing(type: type, id:: object)
        let match = object as! Fixture
        if(following) {
            favouriteFixtures.removeAll { (fixture) -> Bool in
                fixture.fixture_id == match.fixture_id
            }
        } else {
            favouriteFixtures.append(match)
        }
    }
    
    
}
