//
//  RemindersFetchedResultsController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 1/1/20.
//  Copyright © 2020 Andrew Graves. All rights reserved.
//
//  Function: Creates a special kind of FetchedResultsController

import Foundation
import CoreData
import UIKit

class RemindersFetchedResultsController: NSFetchedResultsController<Reminder>, NSFetchedResultsControllerDelegate {
    
    private let tableView: UITableView
    private let context = CoreDataStack.shared.managedObjectContext
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init(fetchRequest: Reminder.fetchRequest(), managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        self.delegate = self
        
        tryFetch()
    }
    
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print("Unresolved error: \(error.localizedDescription)")
        }
    }
    
    // MARK: Fetched results controller delegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        case .update, .move:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
