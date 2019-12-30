//
//  Reminder+CoreDataProperties.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var name: String
    @NSManaged public var detail: String?
    @NSManaged public var alertOnArrival: Bool
    @NSManaged public var isRecurring: Bool
    @NSManaged public var creationDate: Date?
    @NSManaged public var uuid: UUID?
    @NSManaged public var location: Location?

}

extension Reminder {
    
    @nonobjc class func with(_ name: String, description: String?, alertOnArrival: Bool, isRecurring: Bool, creationDate: Date, location: Location, inContext context: NSManagedObjectContext) -> Reminder {
        
        let reminder = Reminder(context: context)
        
        reminder.name = name
        
        if let description = description {
            reminder.detail = description
        }
        
        reminder.alertOnArrival = alertOnArrival
        reminder.isRecurring = isRecurring
        reminder.location = location
        
        return reminder
    }
}
