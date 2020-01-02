//
//  NotificationManager.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/31/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//  PURPOSE: Manages all the notification queue and notification things

import Foundation
import CoreLocation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    
    // Asks the user if the app can display notifications
    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound]) {
            granted, error in
            
            if granted {
                print("Granted")
            } else {
                print("Not Granted")
                fatalError()
            }
        }
    }
    
    // Create a notification with the given reminder variable
    func createNotification(with reminder: Reminder) {
        requestAuthorization()
        
        // Set the circular region that will trigger the notification
        let center = CLLocationCoordinate2D(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
        let region = CLCircularRegion(center: center, radius: 50, identifier: reminder.uuid.uuidString)
        
        // Depending on what the user selected, trigger the alert on exit or entrance
        if reminder.alertOnArrival {
            region.notifyOnEntry = true
            region.notifyOnExit = false

        } else {
            region.notifyOnEntry = false
            region.notifyOnExit = true
        }
        
        // Create the content of the notification
        let content = UNMutableNotificationContent()
        content.title = "Reminder Triggered"
        if let address = reminder.location.address {
            content.subtitle = address
        }
        content.body = reminder.name
        content.sound = UNNotificationSound.default
        
        //  Create the trigger that activates the notification
        let trigger = UNLocationNotificationTrigger(region: region, repeats: reminder.isRecurring)
        let request = UNNotificationRequest(identifier: reminder.uuid.uuidString, content: content, trigger: trigger)
        
        // Add the notification to the notification queue
        self.center.add(request) { (error) in
            if error != nil {
                print("error")
            }
        }
    }
    
    // Removes a notification with a certain identifier
    func removeNotification(withIdentifier identifier: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier.uuidString])
    }
    
    // Prints out the identifiers from every notification waiting in the queue
    func getAllNotifications() {
        center.getPendingNotificationRequests { requests in
            for request in requests {
                print(request.identifier)
            }
        }
    }
}
