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
	
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: module)
		do {
			try container.persistentStoreCoordinator.addPersistentStore(
				ofType: NSSQLiteStoreType,
				configurationName: nil,
				at: self.persistentStoreURL,
				options: [
					NSMigratePersistentStoresAutomaticallyOption: true,
					NSInferMappingModelAutomaticallyOption: true
				]
			)
		} catch {
			fatalError("Persistent store error! \(error)")
		}
		container.loadPersistentStores {
			(storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	lazy var context: NSManagedObjectContext = {
		return self.persistentContainer.viewContext
	}()
	
	lazy var applicationDocumentsDirectory: URL = {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
	}()
	
	lazy var persistentStoreURL: URL = {
		return self.applicationDocumentsDirectory.appendingPathComponent("\(module).sqlite")
	}()
	
	lazy var persistentStoreDescription: NSPersistentStoreDescription = {
		let persistentStoreDescription = NSPersistentStoreDescription()
		persistentStoreDescription.shouldMigrateStoreAutomatically = true
		persistentStoreDescription.shouldInferMappingModelAutomatically = false
		
		return persistentStoreDescription
	}()
	
	// MARK: - Core Data Saving support
	
	func saveContext () {
		let context = persistentContainer.viewContext
		let privateContext = persistentContainer.newBackgroundContext()
		
		guard context.hasChanges || privateContext.hasChanges else {
			return
		}
		
		context.performAndWait {
			do {
				try context.save()
			} catch {
				fatalError("Error saving main managed object context! \(error)")
			}
		}
		
		privateContext.perform {
			do {
				try privateContext.save()
			} catch {
				fatalError("Error saving private managed object context! \(error)")
			}
		}
	}

}
