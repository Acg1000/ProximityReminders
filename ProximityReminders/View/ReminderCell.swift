//
//  ReminderCell.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//  PURPOSE: Acts as the backing class for the cell in the ReminderView

import UIKit

class ReminderCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var triggerLabel: UILabel!
    @IBOutlet weak var repeatsLabel: UILabel!
    
    static let reuseIdentifier = "reminderCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // A method that populates the cell with given attributes
    func configure(title: String, location: Location, alertOnArrival: Bool, repeats: Bool) {
        
        titleLabel.text = title
        locationLabel.text = location.address
        
        if alertOnArrival {
            triggerLabel.text = "On Arrival"
        } else {
            triggerLabel.text = "On Departure"
        }
        
        if repeats {
            repeatsLabel.text = "true"
        } else {
            repeatsLabel.text = "false"
        }
    }
}
