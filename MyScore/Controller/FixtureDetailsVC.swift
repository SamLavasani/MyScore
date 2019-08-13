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
    override func viewDidLoad() {
        setupTransparentNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
