//
//  Location+CoreDataProperties.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var address: String?
    @NSManaged public var city: String?

}

extension Location {
    
    @nonobjc class func with(longitude: Double, latitude: Double, address: String?, city: String?, inContext context: NSManagedObjectContext) -> Location {
        
        let location = Location(context: context)
        
        location.longitude = longitude
        location.latitude = latitude
        location.address = address
        location.city = city
        
        return location
    }
}
