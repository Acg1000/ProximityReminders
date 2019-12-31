//
//  RemindersDataSource.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/30/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import CoreData
import UIKit

class RemindersDataSource: NSObject, UITableViewDataSource {
    
    private let tableView: UITableView
    private let fetchedResultsController: NSFetchedResultsController<Reminder>
    
    init(fetchRequest: NSFetchRequest<Reminder>, managedObjectContext context: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Fetch request or context was invalid")
        }
        
        super.init()
        self.fetchedResultsController.delegate = self
    }
    
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
