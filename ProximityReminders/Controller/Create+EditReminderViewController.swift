//
//  Create+EditReminderViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import UIKit

class Create_EditReminderViewController: UIViewController {
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addLocationButton: UIButton!
    @IBOutlet weak var approachingSwitcher: UISegmentedControl!
    @IBOutlet weak var singleUseSwitcher: UISegmentedControl!
    
    // MARK: Creation Variables
    var isEditingReminder = false
    var location: Location? = nil
    var alertOnArrival: Bool = true
    var isRecurring: Bool = true
    
    // MARK: Other variables
    var date: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
        
    // MARK: Button Functions
    @IBAction func savePressed(_ sender: Any) {
        if let name = textField.text, let location = location { 
            
            if isEditingReminder {
                // needs implementation
                
            } else {
                let _ = Reminder.with(name, description: nil, alertOnArrival: alertOnArrival, isRecurring: isRecurring, creationDate: date, location: location, inContext: AppDelegate.sharedManagedObjectContext)
            }
            
        } else {
            
            // Create an alert and ask for more input
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addLocationPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func approachingSwitched(_ sender: Any) {
        switch approachingSwitcher.selectedSegmentIndex {
        case 0: alertOnArrival = true; print("alert on arrival")
        case 1: alertOnArrival = false; print("alert on departure")
        default:
            alertOnArrival = true
        }
    }
    
    @IBAction func singleUseSwitched(_ sender: Any) {
        switch singleUseSwitcher.selectedSegmentIndex {
        case 0: isRecurring = true; print("single use")
        case 1: isRecurring = false; print("repeat")
        default:
            alertOnArrival = true
        }
    }
}
