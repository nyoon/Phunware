//
//  TimelineEventDetailViewController.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/11/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

class TimelineEventDetailViewController: UIViewController {
	
	@IBOutlet weak var customNavigationView: CustomNavigationView!
	
	@IBOutlet weak var headerImageView: UIImageView!
	@IBOutlet weak var customOverlayView: CustomOverlayView!
	
	@IBOutlet weak var scrollView: UIScrollView!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var locationLine1Label: UILabel!
	@IBOutlet weak var locationLine2Label: UILabel!
	@IBOutlet weak var phoneLabel: UILabel!
	@IBOutlet weak var detailLabel: UILabel!
	
	var timelineEvent: TimelineEvent?
	var image: UIImage?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentSize.height + 100)
		setupCustomNavigationBar()
    }
	
	private func setupCustomNavigationBar() {
		//Setup button callbacks
		customNavigationView.backButtonAction = { [unowned self] in
			let transition = CATransition()
			transition.duration = 0.8
			transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
			transition.type = kCATransition
			transition.subtype = kCATransitionReveal
			self.view.window?.layer.add(transition, forKey: nil)
			self.dismiss(animated: false, completion: nil)
		}
		
		customNavigationView.shareButtonAction = { [unowned self] in
			guard let title = self.titleLabel.text, let detail = self.detailLabel.text else { return }
			let activityItems = [title, detail]
			let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
			if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
				activityViewController.popoverPresentationController?.sourceView = self.view
			}
			self.present(activityViewController, animated: true, completion: nil)
		}
	}
	
	private var contentSize: CGRect {
		var contentRect: CGRect = .zero
		
		for view in scrollView.subviews {
			contentRect = contentRect.union(view.frame)
		}
		
		return contentRect
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		setNeedsStatusBarAppearanceUpdate()
		
		guard let timelineEvent = timelineEvent else { return }
		
		if let image = image {
			headerImageView.image = image
		}
		
		let formattedDate = (timelineEvent.date as Date).formattedDate()
		dateLabel.text = "\(formattedDate)"
		titleLabel.text = timelineEvent.title
		locationLine1Label.text = timelineEvent.locationLine1
		locationLine2Label.text = timelineEvent.locationLine2
		phoneLabel.text = timelineEvent.phone
		detailLabel.text = timelineEvent.detail
		
		customNavigationView.titleLabel.text = timelineEvent.title
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		customNavigationView.backButton.isHidden = false
		customNavigationView.shareButton.isHidden = false
	}
}

extension TimelineEventDetailViewController: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		
		let contentOffsetY = scrollView.contentOffset.y
		let scrollViewHeight = scrollView.frame.size.height
		
		// Expands and shrinks the imageView
		let scale = 1 + fabs(contentOffsetY) / scrollViewHeight
		headerImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
		customOverlayView.transform = CGAffineTransform(scaleX: scale, y: scale)
		
		
		// Fades in and out the nav bar
		let imageHeight = headerImageView.frame.height
		let alphaOffset = imageHeight - (imageHeight / 4)
		let alpha = contentOffsetY / alphaOffset
		
		customNavigationView.backgroundColor = UIColor.lightGray.withAlphaComponent(alpha)
		customNavigationView.titleLabel.textColor = UIColor.white.withAlphaComponent(alpha)
	}
}
