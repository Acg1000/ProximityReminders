//
//  CoreDataStack.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ProximityReminders")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved Error: \(error), \(error.userInfo)")
            }
                
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
            
        return container
    }()
}


extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                print("Saving changes")
                try save()
            } catch {
                fatalError("Error: \(error.localizedDescription): \(userInfo)")
            }
        }
    }
}
