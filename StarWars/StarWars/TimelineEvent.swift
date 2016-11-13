//
//  TimelineEvent.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/9/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit
import CoreData

class TimelineEvent: NSManagedObject {
	static var images = [String : UIImage]()
	
	static func clear() {
		// Clear the record out before populating
		images = [String : UIImage]()
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TimelineEvent")
		if #available(iOS 9.0, *) {
			let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
			do {
				try CoreDataStack.shared.context.execute(batchDeleteRequest)
			} catch {
				print("Could not delete all records of timelineEvent")
			}
		} else {
			// Fallback on earlier versions
			do {
				if let timelineEvents = try CoreDataStack.shared.context.fetch(fetchRequest) as? [TimelineEvent] {
					for timelineEvent in timelineEvents {
						CoreDataStack.shared.context.delete(timelineEvent)
						CoreDataStack.shared.saveContext()
					}
				}
			} catch {
				print("Could not delete all records of timelineEvent")
			}
		}
	}
	
	static func insert(into entity: NSEntityDescription, for jsonArray: [[String: AnyObject?]]) {
		for event in jsonArray {
			guard let id = event["id"] as? Int16,
				let detail = event["description"] as? String,
				let title = event["title"] as? String,
				let timestamp = event["timestamp"] as? String,
				let imageHost = event["image"] as? String?, // Check for response returning NULL
				let dateString = event["date"] as? String,
				let locationLine1 = event["locationline1"] as? String,
				let locationLine2 = event["locationline2"] as? String
				else { fatalError("Could not parse event objects") }
			
			let timelineEvent = TimelineEvent(entity: entity, insertInto: CoreDataStack.shared.context)
			timelineEvent.id = id
			timelineEvent.detail = detail
			timelineEvent.title = title
			timelineEvent.timestamp = timestamp.date as NSDate
			timelineEvent.imageHost = nil
			timelineEvent.date = dateString.date as NSDate
			timelineEvent.locationLine1 = locationLine1
			timelineEvent.locationLine2 = locationLine2
			
			// Edge case where phone number is not an actual field
			if let phone = event["phone"] as? String {
				timelineEvent.phone = phone
			} else {
				timelineEvent.phone = nil
			}
			
			// Use the imageHost url and save to disk
			if let imageHost = imageHost, let url = URL(string: imageHost) {
				url.downloadImageAndSave { (data, response, error) in
					guard let data = data else { print("Failed to get image from server"); return }
					
					// Needs to be on main thread for UI updates
					DispatchQueue.main.async {
						// Store into disk for UI to use
						guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { print("Could not retrieve file"); return }
						
						let path = documentDirectory.appendingPathComponent(url.lastPathComponent)
						do {
							try data.write(to: path, options: .atomic)
							timelineEvent.imageHost = url.lastPathComponent
							CoreDataStack.shared.saveContext()
							
							guard let image = UIImage(data: data),
								let imageHost = timelineEvent.imageHost else { fatalError("Could not create image") }
							images[imageHost] = image
						} catch {
							print("Failed to save image data to disk")
						}
					}
				}
			}
		}
	}
}

extension TimelineEvent {
	
	@nonobjc class func fetchRequest() -> NSFetchRequest<TimelineEvent> {
		return NSFetchRequest<TimelineEvent>(entityName: "TimelineEvent")
	}
	
	@NSManaged var id: Int16
	@NSManaged var detail: String
	@NSManaged var title: String
	@NSManaged var timestamp: NSDate
	@NSManaged var imageHost: String?
	@NSManaged var phone: String?
	@NSManaged var date: NSDate
	@NSManaged var locationLine1: String
	@NSManaged var locationLine2: String
	
}
