//
//  RemindersViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import CoreData
import UIKit

class RemindersViewController: UITableViewController {
    
    var container: NSPersistentContainer!
    var context = CoreDataStack.shared.managedObjectContext
    
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
