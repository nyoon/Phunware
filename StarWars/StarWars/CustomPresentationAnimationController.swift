//
//  CustomPresentationAnimationController.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/11/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

class CustomPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
	
	var yOffset: CGFloat?
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return 2.0
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let fromViewController = transitionContext.viewController(forKey: .from),
			let toViewController = transitionContext.viewController(forKey: .to) as? TimelineEventDetailViewController else { return }
		let finalFrameForViewController = transitionContext.finalFrame(for: toViewController)
		let containerView = transitionContext.containerView
		
		guard let yOffset = yOffset else { fatalError("Y offset was not set") }
		toViewController.view.frame = finalFrameForViewController.offsetBy(dx: 0, dy: yOffset)
		containerView.addSubview(toViewController.view)
		
		UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.2, usingSpringWithDamping: 0.75, initialSpringVelocity: 3.0, options: [.curveEaseInOut], animations: {
			fromViewController.view.alpha = 1
			toViewController.view.frame = finalFrameForViewController
			toViewController.customOverlayView.isHidden = false
		}, completion: { _ in
			transitionContext.completeTransition(true)
			fromViewController.view.alpha = 1.0

		})
		
	}
}
