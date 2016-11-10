//
//  TimelineEvent.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/9/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import Foundation
import CoreData

class TimelineEvent: NSManagedObject {
	
}

extension TimelineEvent {
	
	@nonobjc class func fetchRequest() -> NSFetchRequest<TimelineEvent> {
		return NSFetchRequest<TimelineEvent>(entityName: "TimelineEvent")
	}
	
	@NSManaged var id: Int16
	@NSManaged var detail: String
	@NSManaged var title: String
	@NSManaged var timestamp: Date
	@NSManaged var imageHost: String?
	@NSManaged var phone: String?
	@NSManaged var date: Date
	@NSManaged var locationLine1: String
	@NSManaged var locationLine2: String
	
}
