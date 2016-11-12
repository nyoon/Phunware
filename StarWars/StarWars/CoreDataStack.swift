//
//  CoreDataStack.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/9/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack: NSObject {
	static let module = "StarWars"
	static let shared = CoreDataStack()
	
	func saveContext() {
		guard context.hasChanges || saveManagedObjectContext.hasChanges else {
			return
		}
		
		context.performAndWait() {
			do {
				try self.context.save()
			} catch {
				fatalError("Error saving main managed object context! \(error)")
			}
		}
		
		saveManagedObjectContext.perform() {
			do {
				try self.saveManagedObjectContext.save()
			} catch {
				fatalError("Error saving private managed object context! \(error)")
			}
		}
		
	}
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		let modelURL = Bundle.main.url(forResource: module, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	lazy var applicationDocumentsDirectory: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
	}()
	
	lazy var persistentStoreURL: URL = {
		return self.applicationDocumentsDirectory.appendingPathComponent("\(module).sqlite")
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
			                                   configurationName: nil,
			                                   at: self.persistentStoreURL,
			                                   options: [NSMigratePersistentStoresAutomaticallyOption: true,
			                                             NSInferMappingModelAutomaticallyOption: false])
		} catch {
			fatalError("Persistent store error! \(error)")
		}
		
		return coordinator
	}()
	
	private lazy var saveManagedObjectContext: NSManagedObjectContext = {
		let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		moc.persistentStoreCoordinator = self.persistentStoreCoordinator
		return moc
	}()
	
	lazy var context: NSManagedObjectContext = {
		let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		managedObjectContext.parent = self.saveManagedObjectContext
		return managedObjectContext
	}()
}
