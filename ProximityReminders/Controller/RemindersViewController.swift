//
//  RemindersViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//  FUNCTION: Serves as the view controller for the reminder tableview

import CoreData
import UIKit

class RemindersViewController: UITableViewController {
    
    var container: NSPersistentContainer!
    var context = CoreDataStack.shared.managedObjectContext
    var notificationManager = NotificationManager.shared
    
    private let fetchedResultsController: NSFetchedResultsController = {
        return NSFetchedResultsController(fetchRequest: Reminder.fetchRequest(), managedObjectContext: CoreDataStack.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error)
        }

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 79.5
        notificationManager.center.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath)
        
        if let reminderCell = cell as? ReminderCell {
            let reminder = fetchedResultsController.object(at: indexPath)
            reminderCell.configure(title: reminder.name, location: reminder.location, alertOnArrival: reminder.alertOnArrival, repeats: reminder.isRecurring)
        }
        
        return cell
    }
    
    // Delete functionality
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if case .delete = editingStyle {
            let reminder = fetchedResultsController.object(at: indexPath)
            
            notificationManager.removeNotification(withIdentifier: reminder.uuid)
            reminder.delete()
        }
    }
    
    // MARK: Delegate Methods
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedReminder = fetchedResultsController.object(at: indexPath)
        let editReminderController = storyboard?.instantiateViewController(withIdentifier: "CreateReminderController") as! Create_EditReminderViewController
        editReminderController.setupView(withReminder: selectedReminder)
        
        self.present(editReminderController, animated: true, completion: nil)
    }
}

// MARK: Extensions

extension RemindersViewController: UNUserNotificationCenterDelegate {
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Will present triggered")
        
        // Get the identifier of the notification to query all the reminders
        let uuid = notification.request.identifier
        
        guard let reminders = fetchedResultsController.fetchedObjects else { return }
        
        for reminder in reminders {
            if reminder.uuid.uuidString == uuid && !reminder.isRecurring {
                reminder.delete()
                
            } else if reminder.uuid.uuidString == uuid && reminder.isRecurring {
                let editReminderController = storyboard?.instantiateViewController(withIdentifier: "CreateReminderController") as! Create_EditReminderViewController
                editReminderController.setupView(withReminder: reminder)
                
                self.present(editReminderController, animated: true, completion: nil)
            }
        }
        
        completionHandler([.alert, .badge, .sound])
    }
    
    // This method will be called when the app recieves notifications in the background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let uuid = response.notification.request.identifier
        
        guard let reminders = fetchedResultsController.fetchedObjects else { return }
        
        for reminder in reminders {
            if reminder.uuid.uuidString == uuid && !reminder.isRecurring {
                reminder.delete()
                
            } else if reminder.uuid.uuidString == uuid && reminder.isRecurring {
                let editReminderController = storyboard?.instantiateViewController(withIdentifier: "CreateReminderController") as! Create_EditReminderViewController
                editReminderController.setupView(withReminder: reminder)
                self.present(editReminderController, animated: true, completion: nil)
            }
        }
        
        completionHandler()
    }
}

extension RemindersViewController: NSFetchedResultsControllerDelegate {
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
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        @unknown default: break
        }
    }
        
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
