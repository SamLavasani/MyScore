//
//  ViewController.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import Alamofire

class CompetitionsVC: UIViewController {
    
    
    @IBOutlet weak var competitionsTableView: UITableView!
    let cellId = "MyCell"
    
    var country : Country?
    var allLeagues : [League] = []
    var following : [League] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable()
        getAllLeagues()
        setNeedsStatusBarAppearanceUpdate()
        setupTransparentNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        competitionsTableView.reloadData()
//        if Storage.fileExists(.leagues, in: .documents) {
//            following = Storage.retrieve(.leagues, from: .documents, as: [League].self)
//        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupTransparentNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
    
    func setupTable() {
        competitionsTableView.delegate = self
        competitionsTableView.dataSource = self
        competitionsTableView.separatorStyle = .none
        competitionsTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    //Mark: Competition request
    func getAllLeagues() {
        
        guard let countryName = country?.country else { return }
        let filter = "/country/\(countryName)/\(DateHelper.getCurrentYear())"
        guard let url = URL(string: MyScoreURL.leagues + filter) else { return }
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let leagueData = try JSONDecoder().decode(LeaguesResponse.self, from: data)
                self?.allLeagues = leagueData.api.leagues
                self?.competitionsTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    //MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CompetitionDetailsVC
        if let indexPath = competitionsTableView.indexPathForSelectedRow {
            let league = allLeagues[indexPath.row]
            destinationVC.selectedLeague.league = league
        }
        
    }

}

//MARK: Tableview datasource and delegate

extension CompetitionsVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLeagues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let league = allLeagues[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
        cell.setLeague(league: league)
        cell.delegate = self
        cell.mainLabel.text = league.name
        cell.followButton.isSelected = FollowHelper.isFollowing(type: .leagues, id: league.league_id)
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCompDetails", sender: self)
        
    }
}

//MARK: Delegates

extension CompetitionsVC: FollowDelegate {

    func didTapFollowButton<T>(object: T, type: Type) {
        let comp = object as! League
        let follow = FollowHelper.isFollowing(type: type, id: comp.league_id)
        if(follow) {
            following.removeAll { (competition) -> Bool in
                competition.league_id == comp.league_id
            }
        } else {
            following.append(comp)
        }
        Storage.store(following, to: .documents, as: .leagues)
    }

}

