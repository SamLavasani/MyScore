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
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
        slideAnimationForFixture()
        slideAnimationForTable()
    }
    
    override func viewDidLayoutSubviews() {
        setupUnderLine()
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
                let competition = favouriteCompetitions[indexPath.row]
                destinationVC.selectedCompetition = competition
            }
        } else if (segue.identifier == "goToFixtureDetails") {
            
        } else {
            
        }
    }
    
    
    @IBAction func teamsPressed(_ sender: UIButton) {
        sender.isSelected = true
        state = .teams
        leaguesButton.isSelected = false
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        self.followingTable.reloadData()
        slideAnimationForTable()
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
        slideAnimationForTable()
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
                let team = favouriteTeams[indexPath.row]
                let isFollowing = FollowHelper.isFollowing(type: .team, object: team)
                cell.mainLabel.text = team.name
                let followImage = isFollowing ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
                cell.followButton.imageView?.image = followImage
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
        followingTable.reloadData()
        fixtureTable.reloadData()
    }
    
}
