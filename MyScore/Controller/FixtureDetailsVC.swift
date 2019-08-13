//
//  FixtureDetailsVC.swift
//  MyScore
//
//  Created by Samuel on 2019-08-13.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class FixtureDetailsVC : UIViewController {
    
    var fixtureID : Int!
    var fixture : Fixture?
    
    override func viewDidLoad() {
        setupTransparentNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        getFixtureDetails()
    }
    
    func getFixtureDetails() {
        let id = String(fixtureID)
        let urlString = MyScoreURL.fixture + "\(id)"
        guard let url = URL(string: urlString) else { return }
        APIManager.shared.request(url: url, onSuccess: { [weak self] (data) in
            do {
                let fixtureData = try JSONDecoder().decode(FixturesResponse.self, from: data)
                self?.fixture = fixtureData.api.fixtures.first
            } catch {
                print(error)
            }
        }) { (error) in
            print(error)
        }
    }
}
