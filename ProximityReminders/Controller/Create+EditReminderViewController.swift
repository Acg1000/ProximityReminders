//
//  Create+EditReminderViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import UIKit
import MapKit

class Create_EditReminderViewController: UIViewController {
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var approachingSwitcher: UISegmentedControl!
    @IBOutlet weak var singleUseSwitcher: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Helper Classes
    lazy var locationManager: LocationManager = {
        return LocationManager(locationDelegate: self, permissionsDelegate: nil)
    }()
    
    
    // MARK: Creation Variables
    var isEditingReminder = false
    var location: Location? = nil
    var alertOnArrival: Bool = true
    var isRecurring: Bool = true
    
    
    // MARK: Other variables
    var date: Date = Date()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMap()
    }
    
    // MARK: Helper functions
    func createAlert(withTitle title: String, andDescription description: String){
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func setupMap() {
        mapView.showsUserLocation = true
    }
    
    func goToLocation(_ location: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    func populateViewWithPlacemark(_ placemark: CLPlacemark) {
        if let name = placemark.name, let locality = placemark.locality {
            locationTextField.text = "\(name), \(locality)"

        }
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
    
    @IBAction func getCurrentLocation(_ sender: Any) {
        print("Get current location")
        locationManager.requestLocation()
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

extension Create_EditReminderViewController: LocationManagerDelegate {
    func obtainedLocation(_ location: CLLocation) {
        print("obtained location!")
        goToLocation(location)
    }
    
    func obtainedPlacemark(_ placemark: CLPlacemark) {
        print("obtained placemark")
        populateViewWithPlacemark(placemark)
    }
    
    func failedWithError(_ error: LocationError) {
        switch error {
        case .disallowedByUser:
            createAlert(withTitle: "Location Access Needed", andDescription: "Please allow access to the location data to use this feature")

        case .unableToFindLocation:
            createAlert(withTitle: "Unable to Find Location", andDescription: "Somthing went wrong with the retrevial of your location...")
            
        case .unknownError:
            createAlert(withTitle: "Unknown Error", andDescription: "There was an unknown error...")
        }
    }
}
