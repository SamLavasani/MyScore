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
    
    var favouriteCompetitions : [Competition] = []
    var favouriteTeams : [Team] = []
    var favouriteFixtures : [Match] = []
    var shapeLayer = CAShapeLayer()
    let cellId = "MyCell"
    private var state : State = .teams
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followingTable.delegate = self
        followingTable.dataSource = self
        fixtureTable.delegate = self
        fixtureTable.dataSource = self
        followingTable.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Storage.fileExists(.competition, in: .documents) {
            favouriteCompetitions = Storage.retrieve(.competition, from: .documents, as: [Competition].self)
        }
        followingTable.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
        switch state {
        case .teams:
            let team = favouriteTeams[indexPath.row]
            cell.mainLabel.text = team.name
            return cell
        case .leagues:
            let competition = favouriteCompetitions[indexPath.row]
            let isFollowing = CompetitionHelper.isUserFollowingCompetition(comp: competition)
            cell.setCompetition(comp: competition)
            cell.delegate = self
            cell.mainLabel.text = competition.name
            cell.followButton.isSelected = isFollowing
            let followImage = isFollowing ? #imageLiteral(resourceName: "follow-selected") : #imageLiteral(resourceName: "follow")
            cell.followButton.imageView?.image = followImage
            return cell
        }
    }
}

extension FavouritesVC: FollowCompetitionDelegate {
    
    func didTapFollowButton(comp: Competition) {
        if(CompetitionHelper.isUserFollowingCompetition(comp: comp)) {
           CompetitionHelper.unfollowCompetition(comp: comp)
            followingTable.reloadData()
        }
        else {
            favouriteCompetitions.append(comp)
            Storage.store(favouriteCompetitions, to: .documents, as: .competition)
        }
    }
    
}
