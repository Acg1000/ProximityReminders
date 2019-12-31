//
//  Create+EditReminderViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import UIKit
import MapKit
import MobileCoreServices

class Create_EditReminderViewController: UIViewController {
    @IBOutlet weak var titleLabel: UINavigationItem!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var approachingSwitcher: UISegmentedControl!
    @IBOutlet weak var singleUseSwitcher: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var getCurrentLocationButton: UIButton!
    
    // MARK: Helper Classes
    lazy var locationManager: LocationManager = {
        return LocationManager(locationDelegate: self, permissionsDelegate: nil)
    }()
    let context = CoreDataStack.shared.managedObjectContext
    var wasDismissedDelegate: WasDismissedDelegate?
    
    
    // MARK: Creation Variables
    var isEditingReminder = false
    var clLocation: CLLocation? = nil {
        didSet {
            if let clLocation = clLocation {
                print("Location was set")
                goToLocation(clLocation)
            }
        }
    }
    var placemark: CLPlacemark? = nil {
        didSet {
            if let placemark = placemark {
                print("placemark was set")
                populateViewWithPlacemark(placemark)

            }
        }
    }
    var alertOnArrival: Bool = true
    var isRecurring: Bool = true
    
    
    // MARK: Other variables
    var date: Date = Date()
    
    // MARK: Editing Variable
    var editingReminder: Reminder?
    
    
    // MARK: View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup
        setupMap()
        titleField.delegate = self
        locationTextField.isEnabled = false
        
        // Keyboard notification manager
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Map longpress setup
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed))
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        getCurrentLocationButton.tintColor = .gray
        
        if isEditingReminder {
            titleLabel.title = "Create Reminder"
            
            if let reminder = editingReminder {
                titleField.text = reminder.name
                clLocation = CLLocation(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
                
                // Getting the address
                if let address = reminder.location.address, let city = reminder.location.city {
                    locationTextField.text = "\(address), \(city)"
                }
                
                if reminder.alertOnArrival {
                    approachingSwitcher.selectedSegmentIndex = 0
                } else {
                    approachingSwitcher.selectedSegmentIndex = 1
                }
                
                if reminder.isRecurring {
                    singleUseSwitcher.selectedSegmentIndex = 1
                } else {
                    singleUseSwitcher.selectedSegmentIndex = 0
                }
                
                
                // TODO: REMOVE THIS AND CREATE A CLASS FOR IT
                
                // Remove the annotations that exist
                mapView.removeAnnotations(mapView.annotations)
                
                let point = MKPointAnnotation()
                point.coordinate = CLLocationCoordinate2D(latitude: reminder.location.latitude, longitude: reminder.location.longitude)
                
                locationManager.getPlacemark(from: CLLocation(latitude: reminder.location.latitude, longitude: reminder.location.longitude)) { placemark in
                    
                    // Set the pin details
                    point.title = placemark?.name
                    point.subtitle = placemark?.locality
                    
                    // Set the placemark
                    self.placemark = placemark
                    
                }
                
                // Add the annotation
                mapView.addAnnotation(point)
                getCurrentLocationButton.tintColor = .gray
            }

        } else {
            titleLabel.title = "Edit Reminder"

        }
    }
    
    // MARK: Helper functions
    func createAlert(withTitle title: String, andDescription description: String){
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    func goToLocation(_ location: CLLocation) {
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: Preperation
    func setupView(withReminder reminder: Reminder) {
        isEditingReminder = true
        editingReminder = reminder
    }
    
    func setupMap() {
        mapView.showsUserLocation = true
    }
    
    func populateViewWithPlacemark(_ placemark: CLPlacemark) {
        if let name = placemark.name, let locality = placemark.locality {
            locationTextField.text = "\(name), \(locality)"

        }
    }
        
    // MARK: Button Functions
    @IBAction func savePressed(_ sender: Any) {
        guard let name = titleField.text, !name.isEmpty else { createAlert(withTitle: "Title needed", andDescription: "Please enter a title to save"); return }
        guard let location = clLocation else { createAlert(withTitle: "Location needed", andDescription: "Please enter a location to save"); return }
        
        if isEditingReminder {
            if let reminder = editingReminder {
                // TITLE
                if let name = titleField.text {
                    reminder.setValue(name, forKey: "name")
                }
                
                // LOCATION
                if let address = reminder.location.address, let city = reminder.location.city {
                    reminder.setValue(Location.with(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, address: address, city: city, inContext: context), forKey: "location")
                } else {
                    reminder.setValue(Location.with(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, address: nil, city: nil, inContext: context), forKey: "location")
                }
                
                
                // Recurring AND Alert
                reminder.setValue(isRecurring, forKey: "isRecurring")
                reminder.setValue(alertOnArrival, forKey: "alertOnArrival")
                
                // Saving the changes
                context.saveChanges()
                dismiss(animated: true, completion: nil)
                wasDismissedDelegate?.wasDismissed()
            }
            
        } else {
            guard let placemark = placemark else { createAlert(withTitle: "Location needed", andDescription: "Please enter a location to save"); return }

            
            let location = Location.with(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, address: placemark.name, city: placemark.locality, inContext: context)
            
            let _ = Reminder.with(name, description: nil, alertOnArrival: alertOnArrival, isRecurring: isRecurring, creationDate: date, location: location, inContext: context)
            
            context.saveChanges()
            dismiss(animated: true, completion: nil)
            wasDismissedDelegate?.wasDismissed()

        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func mapLongPressed(gestureRecogniser: UIGestureRecognizer) {
        
        // Remove the annotations that exist
        mapView.removeAnnotations(mapView.annotations)
        
        // get the point where the user touched and turn it into a set of coordinates
        let touchPoint = gestureRecogniser.location(in: self.mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let point = MKPointAnnotation()
        point.coordinate = touchMapCoordinate
        
        // Set the location for the class
        clLocation = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        
        locationManager.getPlacemark(from: CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)) { placemark in
            
            // Set the pin details
            point.title = placemark?.name
            point.subtitle = placemark?.locality
            
            // Set the placemark
            self.placemark = placemark
            
        }
        
        // Add the annotation
        mapView.addAnnotation(point)
        getCurrentLocationButton.tintColor = .gray

    }
    
    @IBAction func getCurrentLocation(_ sender: Any) {
        print("Get current location")
        locationManager.requestLocation()
        getCurrentLocationButton.tintColor = .systemBlue
        
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
        case 0: isRecurring = false; print("single use")
        case 1: isRecurring = true; print("repeat")
        default:
            alertOnArrival = true
        }
    }
}


// MARK: Extensions

extension Create_EditReminderViewController: LocationManagerDelegate {
    
    func obtainedPlacemark(_ placemark: CLPlacemark, location: CLLocation) {
        print("obtained placemark")
        
        clLocation = location
        self.placemark = placemark
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

// Make keyboard dismiss when done is pressed on the keyboard
extension Create_EditReminderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {

        textField.resignFirstResponder()
        return true
    }
}


// MARK: Protocols

protocol WasDismissedDelegate {
    func wasDismissed()
}
