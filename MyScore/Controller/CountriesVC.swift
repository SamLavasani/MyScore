//
//  CountriesVC.swift
//  MyScore
//
//  Created by Samuel on 2019-07-10.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class CountriesVC: UIViewController {
    
    var countries : [Country] = []
    let cellId = "MyCell"
    @IBOutlet weak var countriesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        getAllCountries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupTable() {
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        countriesTableView.separatorStyle = .none
        countriesTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    func getAllCountries() {
        guard let url = URL(string: MyScoreURL.countries) else { return }
        print(url)
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let countryData = try JSONDecoder().decode(CountriesResponse.self, from: data)
                self?.countries = countryData.api.countries
                self?.countriesTableView.reloadData()
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CompetitionsVC
        if let indexPath = countriesTableView.indexPathForSelectedRow {
            let country = countries[indexPath.row]
            destinationVC.country = country
        }
    }
}

extension CountriesVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let country = countries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! CustomTableViewCell
        cell.mainLabel.text = country.country
        cell.followButton.isHidden = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToLeagues", sender: self)
    }
    
}
