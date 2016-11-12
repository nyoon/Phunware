//
//  CustomOverlayView.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/11/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

@IBDesignable
class CustomOverlayView: UIView {
	let gradientLayer = CAGradientLayer()
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		gradientLayer.frame = CGRect(x: 0, y: bounds.height/2, width: bounds.width, height: bounds.height/2)
	}
	
	override func prepareForInterfaceBuilder() {
		super.prepareForInterfaceBuilder()
		setup()
	}
	
	@IBInspectable var startColor: UIColor = UIColor.white {
		didSet {
			configure()
		}
	}
	
	@IBInspectable var endColor: UIColor = UIColor.black {
		didSet {
			configure()
		}
	}
	
	func configure() {
		gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
		gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
		gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
	}
	
	func setup() {
		layer.addSublayer(gradientLayer)
	}
}
