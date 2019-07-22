//
//  CustomTableViewCell.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit
import WebKit

protocol FollowDelegate {
    func didTapFollowButton<T>(object: T, type: Type)
}

class CustomTableViewCell: UITableViewCell {
    
    var delegate : FollowDelegate?
    
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    var league : League?
    var team : Team?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true
    }
    
    func setLeague(league: League) {
        self.league = league
        mainLabel.text = league.name
    }
    
    func setTeam(team: Team) {
        self.team = team
        mainLabel.text = team.name
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if let comp = league {
            delegate?.didTapFollowButton(object: comp, type: .leagues)
        }
        if let team = team {
            delegate?.didTapFollowButton(object: team, type: .team)
        }
    }
    
}

class ShadowView: UIView {
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    func setupShadow() {
        self.layer.cornerRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}
