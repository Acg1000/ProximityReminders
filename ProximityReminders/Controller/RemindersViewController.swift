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
    
    override func viewWillAppear(_ animated: Bool) {
        dataSource.refreshData()
    }

    
    
    
    // MARK: Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
