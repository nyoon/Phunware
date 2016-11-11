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
	
	var fetchedResultsController: NSFetchedResultsController<TimelineEvent>!
	let dataManager = TimelineDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		if Reachability.isInternetAvailable {
			TimelineEvent.clear()
		}
		
		loadData()
		print(CoreDataStack.shared.persistentStoreURL)
		
		let fetchRequest: NSFetchRequest<TimelineEvent> = TimelineEvent.fetchRequest()
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(key: "date", ascending: false)
		]
		
		fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: CoreDataStack.shared.context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
		
		fetchedResultsController.delegate = self
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			fatalError("There was an error fetching the list of devices!")
		}
	}
	
	func loadData() {
		let activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
		activityView.startAnimating()
		view.addSubview(activityView)
		activityView.translatesAutoresizingMaskIntoConstraints = false
		activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
		
		dataManager.loadData {
			(data, response, error) in
			
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
		
		timelineCell.dateLabel.text = "\(timelineEvent.date)"
		timelineCell.titleLabel.text = timelineEvent.title
		timelineCell.locationLabel.text = "\(timelineEvent.locationLine1) \(timelineEvent.locationLine2)"
		timelineCell.detailLabel.text = timelineEvent.detail
		timelineCell.backgroundImageView.image = nil
		
		guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
			let imageHost = timelineEvent.imageHost
			else { return timelineCell }
		let path = documentDirectory.appendingPathComponent(imageHost)
		do {
			let data = try Data(contentsOf: path, options: .alwaysMapped)
			let image = UIImage(data: data)
			timelineCell.backgroundImageView.image = image
		} catch {
			print(error)
		}
		
		return timelineCell
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}
}

extension TimelineEventListViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = collectionView.frame.width
		
		if width <= 414 {
			return CGSize(width: width, height: 160)
		} else {
			return CGSize(width: width / 2, height: 160)
		}
	}
}

extension TimelineEventListViewController: UICollectionViewDataSourcePrefetching {
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
	}
}

extension TimelineEventListViewController: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		collectionView.reloadData()
	}
}
