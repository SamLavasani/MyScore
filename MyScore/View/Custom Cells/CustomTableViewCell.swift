//
//  CustomTableViewCell.swift
//  MyScore
//
//  Created by Samuel on 2019-05-20.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

protocol FollowCellDelegate {
    func didTapFollowButton(comp: Competition)
}

class CustomTableViewCell: UITableViewCell {
    
    var delegate : FollowCellDelegate?
    
    @IBOutlet weak var mainBackground: UIView!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    var competition : Competition!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.mainBackground.layer.cornerRadius = 8
        self.mainBackground.layer.masksToBounds = true
    }
    
    func setCompetition(comp: Competition) {
        competition = comp
    }
    
    @IBAction func followButtonPressed(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.didTapFollowButton(comp: competition)
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
