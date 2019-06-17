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
    
    var selectedCompetition : Competition?
    let filterMatches = "/matches?"
    let dateFrom = "dateFrom="
    let dateTo = "&dateTo="
    let leagueCellId = "LeagueTableCell"
    let fixtureCellId = "SmallFixtureCell"
    
    @IBOutlet weak var competitionLabel: UILabel!
    
    @IBOutlet weak var competitionTableView: UITableView!
    @IBOutlet weak var tableButton: UIButton!
    @IBOutlet weak var fixtureButton: UIButton!
    @IBOutlet weak var buttonStackView: UIStackView!
    var shapeLayer = CAShapeLayer()
    private var state : State = .fixtures
    
    var allMatches : [Match] = []
    
    var teamPositions : [TeamPosition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        competitionTableView.delegate = self
        competitionTableView.dataSource = self
        competitionTableView.separatorStyle = .none
        competitionLabel.text = selectedCompetition?.name
        competitionTableView.register(UINib(nibName: "SmallFixtureTableViewCell", bundle: nil), forCellReuseIdentifier: fixtureCellId)
        competitionTableView.register(UINib(nibName: "LeagueTableViewCell", bundle: nil), forCellReuseIdentifier: leagueCellId)
        
        getCompetitionFixtures()
        getTableForCompetition()
        setupTransparentNavBar()
        
    }
    
    func setupTransparentNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
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
    
    func getCurrentDate() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    var path = UIBezierPath()
    
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
        sender.isSelected = true
        tableButton.isSelected = false
        state = .fixtures
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        competitionTableView.reloadData()
    }
    
    @IBAction func tablePressed(_ sender: UIButton) {
        fixtureButton.isSelected = false
        state = .table
        sender.isSelected = true
        let x = fixtureButton.frame.width + 10
        
        UIView.animate(withDuration: 5) {
            self.shapeLayer.frame = CGRect(x: x, y: 0, width: 0, height: 0)
        }
        competitionTableView.reloadData()
    }
    
    func getCompetitionFixtures() {
        guard let url = getFixturesURL() else { return }
        APIManager.shared.apiRequest(url: url, onSuccess: { [weak self] (data) in
            do {
                let competitionData = try JSONDecoder().decode(CompetitionDetailsResponse.self, from: data)
                self?.allMatches = competitionData.matches
                self?.competitionTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func getTableForCompetition() {
        guard let url = getTableStandingsURL() else { return }
        APIManager.shared.apiRequest(url: url, onSuccess: { [weak self] (data) in
            do {
                let competitionData = try JSONDecoder().decode(TableStandingsResponse.self, from: data)
                self?.teamPositions = competitionData.standings[0].table
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    func getFixturesURL() -> URL? {
        guard let competitionID = selectedCompetition?.id else { return nil }
        let currentDate = getCurrentDate()
        guard let endDate = selectedCompetition?.currentSeason?.endDate else { return nil }
        let filterDate = dateFrom + currentDate + dateTo + endDate
        let compURL = MyScoreURL.competitions + "/" + String(competitionID)
        let filter = filterMatches + filterDate
        guard let url = URL(string:compURL + filter) else { return nil }
        return url
    }
    
    func getTableStandingsURL() -> URL? {
        guard let competitionID = selectedCompetition?.id else { return nil }
        let compURL = MyScoreURL.competitions + "/"+String(competitionID)
        let filter = "/standings?standingType=TOTAL"
        guard let url = URL(string:compURL + filter) else { return nil }
        return url
    }
}

extension CompetitionDetailsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch state {
        case .fixtures:
            return allMatches.count
        case .table:
            return teamPositions.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch state {
        case .fixtures:
            let match = allMatches[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: fixtureCellId, for: indexPath) as! SmallFixtureTableViewCell
            let dateInfo = getDateFromString(date: match.utcDate)
            cell.homeTeamLabel.text = match.homeTeam.name
            cell.awayTeamLabel.text = match.awayTeam.name
            cell.dateLabel.text = dateInfo.date
            cell.timeLabel.text = dateInfo.time
            cell.homeTeamScore.isHidden = match.status != "LIVE"
            cell.awayTeamScore.isHidden = match.status != "LIVE"
            return cell
        case .table:
            let position = teamPositions[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: leagueCellId, for: indexPath) as! LeagueTableViewCell
            cell.teamNameLabel.text = position.team.name
            cell.gamesPlayedLabel.text = "P: \(position.playedGames)"
            cell.goalDifferenceLabel.text = "GD: \(position.goalDifference)"
            cell.teamPosition.text = "#\(position.position)"
            cell.pointsLabel.text = "PTS: \(position.points)"
            return cell
        }
    }
    
    
}
