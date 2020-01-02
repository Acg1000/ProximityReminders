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
    
    lazy var dataSource: RemindersDataSource = {
        let request: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        return RemindersDataSource(fetchRequest: request, managedObjectContext: context, tableView: self.tableView)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 79.5
        tableView.dataSource = dataSource
        tableView.delegate = self
        notificationManager.center.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createReminder" {
            let createReminderController = segue.destination as? Create_EditReminderViewController
            createReminderController?.wasDismissedDelegate = self
            
        }
    }
    
    // MARK: Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedReminder = dataSource.reminders[indexPath.row]
        let editReminderController = storyboard?.instantiateViewController(withIdentifier: "CreateReminderController") as! Create_EditReminderViewController
        editReminderController.setupView(withReminder: selectedReminder)
        
        self.present(editReminderController, animated: true, completion: nil)
        
    }
}

// MARK: Extensions

extension RemindersViewController: WasDismissedDelegate {
    func wasDismissed() {
        
        dataSource.refreshData()
        tableView.reloadData()
        
    }
}

extension RemindersViewController: UNUserNotificationCenterDelegate {
    // This method will be called when app received push notifications in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Will present triggered")
        
        // Get the identifier of the notification to query all the reminders
        let uuid = notification.request.identifier
        
        for reminder in dataSource.reminders {
            if reminder.uuid.uuidString == uuid && !reminder.isRecurring {
                context.delete(reminder)
                dataSource.refreshData()
                tableView.reloadData()
                
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
        
        for reminder in dataSource.reminders {
            if reminder.uuid.uuidString == uuid && !reminder.isRecurring {
                context.delete(reminder)
                dataSource.refreshData()
                tableView.reloadData()
                
            } else if reminder.uuid.uuidString == uuid && reminder.isRecurring {
                let editReminderController = storyboard?.instantiateViewController(withIdentifier: "CreateReminderController") as! Create_EditReminderViewController
                editReminderController.setupView(withReminder: reminder)
                self.present(editReminderController, animated: true, completion: nil)
            }
        }
        
        completionHandler()
    }
}
