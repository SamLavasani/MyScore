//
//  SmallFixtureTableViewCell.swift
//  MyScore
//
//  Created by Samuel on 2019-05-22.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class SmallFixtureTableViewCell: UITableViewCell {

    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var homeTeamScore: UILabel!
    
    @IBOutlet weak var awayTeamScore: UILabel!
    
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var awayTeamLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.mainBackgroundView.layer.cornerRadius = 8
        self.mainBackgroundView.layer.masksToBounds = true
    }
    
    func resetCell() {
        homeTeamLabel.text?.removeAll()
        awayTeamLabel.text?.removeAll()
        dateLabel.text?.removeAll()
        timeLabel.text?.removeAll()
    }
    
}
