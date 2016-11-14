//
//  ViewExtension.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/13/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

extension UIView {
	func addCenterConstraints(to view: UIView) {
		if #available(iOS 9.0, *) {
			self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
			self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		} else {
			// Fallback on earlier versions
			NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
			NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
		}
	}
}
