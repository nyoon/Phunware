//
//  TimelineEventListViewController.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/10/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit
import CoreData

class TimelineEventListViewController: UIViewController {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	fileprivate var fetchedResultsController: NSFetchedResultsController<TimelineEvent>!
	fileprivate let dataManager = TimelineDataManager()
	fileprivate var yOffset: CGFloat?

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if Reachability.isInternetAvailable {
			TimelineEvent.clear()
			loadData()
		}
		
		setupFetchRequest()
		TimelineEvent.storeImagesFromDocumentDirectory()
		print(CoreDataStack.shared.persistentStoreURL)
    }
	
	private func setupFetchRequest() {
		let fetchRequest: NSFetchRequest<TimelineEvent> = TimelineEvent.fetchRequest()
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: "date", ascending: true)
		]
		
		fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: CoreDataStack.shared.context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		
		fetchedResultsController.delegate = self
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("There was an error fetching the list of devices!")
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Hide navigation bar for custom navigation bar
		navigationController?.navigationBar.isHidden = false
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.barStyle = .default
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		let width = collectionView.frame.width
		
		if UIDevice.current.userInterfaceIdiom == .pad {
			flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2, height: 250)
			collectionView.reloadData()
		} else {
			flowLayout.itemSize = CGSize(width: width, height: 250)
			collectionView.reloadData()
		}
		
	}
	
	private func loadData() {
		let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		view.addSubview(activityView)
		activityView.startAnimating()
		
		activityView.translatesAutoresizingMaskIntoConstraints = false
		activityView.addCenterConstraints(to: view)
		
		dataManager.loadData { (data, response, error) in
			
			activityView.removeFromSuperview()
			
			guard let timelineEntity = NSEntityDescription.entity(forEntityName: "TimelineEvent", in: CoreDataStack.shared.context)
				else { fatalError("Could not find TimelineEvent entity description") }
			
			do {
				guard let data = data else { return }
				guard let jsonArray = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [[String: AnyObject]]
					else { print("Events could not be serialized"); return }
				
				TimelineEvent.insert(into: timelineEntity, for: jsonArray)
				CoreDataStack.shared.saveContext()
			} catch {
				print(error)
			}
			self.collectionView.reloadData()
			
		}
	}
}

extension TimelineEventListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let timelineCell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimelineCell", for: indexPath) as? TimelineCell
			else { fatalError("Could not create timelineCell") }
		
		let timelineEvent = fetchedResultsController.object(at: indexPath)
		
		let formattedDate = (timelineEvent.date as Date).formattedDate()
		timelineCell.dateLabel.text = "\(formattedDate)"
		timelineCell.titleLabel.text = timelineEvent.title
		timelineCell.locationLabel.text = "\(timelineEvent.locationLine1) \(timelineEvent.locationLine2)"
		timelineCell.detailLabel.text = timelineEvent.detail
		timelineCell.backgroundImageView.image = nil
		if let imageHost = timelineEvent.imageHost {
			timelineCell.backgroundImageView.image = TimelineEvent.images[imageHost]
		}
		
		// Rasterization for scrolling improvements
		timelineCell.layer.shouldRasterize = true
		timelineCell.layer.rasterizationScale = UIScreen.main.scale
		
		return timelineCell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
		if let detailViewController = storyboard.instantiateViewController(withIdentifier: "TimelineEventDetailViewController") as? TimelineEventDetailViewController {
			let timelineEvent = fetchedResultsController.object(at: indexPath)
			detailViewController.timelineEvent = timelineEvent
			if let imageHost = timelineEvent.imageHost {
				detailViewController.image = TimelineEvent.images[imageHost]
			}
			
			guard let cell = self.collectionView.cellForItem(at: indexPath)! as? TimelineCell else { fatalError("Cast to TimelineCell has failed") }
			
			// Custom animation

			UIView.transition(with: cell.overlayView, duration: 0.5, options: [.transitionCrossDissolve], animations: {
				cell.overlayView.isHidden = true
				self.navigationController?.navigationBar.isHidden = true
				for label in [cell.dateLabel, cell.titleLabel, cell.locationLabel, cell.detailLabel] {
					label?.isHidden = true
				}
			}, completion: nil)

			UIView.animate(withDuration: 2.0, animations: {
				self.yOffset = cell.frame.origin.y - collectionView.contentOffset.y
				detailViewController.transitioningDelegate = self
				self.present(detailViewController, animated: true, completion: nil)
			}, completion: { _ in
				cell.overlayView.isHidden = false
				for label in [cell.dateLabel, cell.titleLabel, cell.locationLabel, cell.detailLabel] {
					label?.isHidden = false
				}
			})

		}
	}
}

extension TimelineEventListViewController: UIViewControllerTransitioningDelegate {
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = CustomPresentationAnimationController()
		let navigationBar = navigationController!.navigationBar
		
		guard let yOffset = yOffset else { fatalError("Y offset was not set") }
		animationController.yOffset = yOffset + navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
		return animationController
	}
}

extension TimelineEventListViewController: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		collectionView.reloadData()
	}
}
