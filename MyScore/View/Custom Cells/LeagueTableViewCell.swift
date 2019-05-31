//
//  LeagueTableViewCell.swift
//  MyScore
//
//  Created by Samuel on 2019-05-22.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

class LeagueTableViewCell: UITableViewCell {
    @IBOutlet weak var teamPosition: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var goalDifferenceLabel: UILabel!
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }
    
    func resetCell() {
        teamPosition.text?.removeAll()
        pointsLabel.text?.removeAll()
        goalDifferenceLabel.text?.removeAll()
        gamesPlayedLabel.text?.removeAll()
        teamNameLabel.text?.removeAll()
    }
    
}
