//
//  CustomNavigationView.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/11/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

class CustomNavigationView: UIView {
	
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var shareButton: UIButton!
	
	@IBAction func backButtonTapped(sender: UIButton) {
		backButtonAction?()
	}
	
	@IBAction func shareButtonTapped(sender: UIButton) {
		shareButtonAction?()
	}
	
	var backButtonAction: (() -> ())?
	var shareButtonAction: (() -> ())?
	
}
