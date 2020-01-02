//
//  RemindersDataSource.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/30/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//  PURPOSE: Serves as the datasource for the Reminders Table View

import CoreData
import UIKit

class RemindersDataSource: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    private let context = CoreDataStack.shared.managedObjectContext
    private let notificationManager = NotificationManager.shared
    
    lazy var fetchedResultsController: RemindersFetchedResultsController = {
        return RemindersFetchedResultsController(tableView: self.tableView)
    }()
    
    init(tableView: UITableView) {
        self.tableView = tableView
        
    }
    
    func object(at indexPath: IndexPath) -> Reminder {
        return fetchedResultsController.object(at: indexPath)
    }
    
    // Refreshes the data by fetching a new batch of reminders from Core Data
    func refreshData() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch request or context was invalid")
        }
    }
    
    
    // MARK: DATASOURCE Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "reminderCell", for: indexPath) as! ReminderCell
        cell.configure(title: reminder.name, location: reminder.location, alertOnArrival: reminder.alertOnArrival, repeats: reminder.isRecurring)
        
        return cell
    }
    
    // Delete functionality
 
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = fetchedResultsController.object(at: indexPath)
        
        notificationManager.removeNotification(withIdentifier: item.uuid)
        context.delete(item)
        context.saveChanges()
                 
    }
}


// MARK: Extension
extension RemindersDataSource: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

extension RemindersDataSource {
    var reminders: [Reminder] {
        guard let objects = fetchedResultsController.sections?.first?.objects as? [Reminder] else {
            return []
        }
        
        return objects
    }
}
