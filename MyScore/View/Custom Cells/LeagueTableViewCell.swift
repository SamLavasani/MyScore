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
    @IBOutlet weak var followButton: UIButton!
    
    var delegate : FollowDelegate?
    var team : Team?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        // Initialization code
    }
    
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        guard let team = self.team else { return }
        delegate?.didTapFollowButton(object: team, type: .team)
    }
    
    func setTeam(team: Team) {
        self.team = team
    }
    
    func resetCell() {
        teamPosition.text?.removeAll()
        pointsLabel.text?.removeAll()
        goalDifferenceLabel.text?.removeAll()
        gamesPlayedLabel.text?.removeAll()
        teamNameLabel.text?.removeAll()
    }
    
}
