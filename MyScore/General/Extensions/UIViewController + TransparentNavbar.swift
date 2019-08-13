//
//  UIView + TransparentNavbar.swift
//  MyScore
//
//  Created by Samuel on 2019-08-13.
//  Copyright © 2019 Samuel Lavasani. All rights reserved.
//

import UIKit

extension UIViewController {
    func setupTransparentNavBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
    }
}
