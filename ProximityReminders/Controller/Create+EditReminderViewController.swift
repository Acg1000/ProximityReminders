//
//  Create+EditReminderViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/28/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//
//  FUNCTION: Serves as the View Controller for the Create+EditReminder View

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
    @IBOutlet weak var deleteIcon: UIBarButtonItem!
    
    // MARK: Helper Classes
    lazy var locationManager: LocationManager = {
        return LocationManager(locationDelegate: self, permissionsDelegate: nil)
    }()
    let context = CoreDataStack.shared.managedObjectContext
    var notificationManager = NotificationManager.shared
    
    
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
        locationTextField.delegate = self
        mapView.delegate = self
        getCurrentSwitchStates()
        
        // Keyboard notification manager
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Map longpress setup
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapPressed))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        getCurrentLocationButton.tintColor = .gray
        
        // If the reminder is being edited
        if isEditingReminder {
            titleLabel.title = "Edit Reminder"
            
            if let reminder = editingReminder {
                // Setting the basic variables
                titleField.text = reminder.name
                deleteIcon.isEnabled = true
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
                
                // Add a pin at the saved location to the map
                addPin(at: CLLocation(latitude: reminder.location.latitude, longitude: reminder.location.longitude))

            }

        } else {
            titleLabel.title = "Create Reminder"
            deleteIcon.isEnabled = false

        }
    }
    
    // MARK: Helper functions
    
    // Create an alert with a given title and description
    func createAlert(withTitle title: String, andDescription description: String){
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "dismiss", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // These two functions allow the keyboard to push the view upwards
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
    
    // Shifts the map to a provided location
    func goToLocation(_ location: CLLocation) {
        // create a center and region
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        // Set the map region and overlays
        mapView.setRegion(region, animated: true)
        mapView.removeOverlays(mapView.overlays)
        let mkCircle = MKCircle(center: center, radius: 50)
        mapView.addOverlay(mkCircle)
        
    }
    
    func addPin(at location: CLLocation) {
        // Remove all the current annotations
        mapView.removeAnnotations(mapView.annotations)

        let point = MKPointAnnotation()
        point.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        locationManager.getPlacemark(from: CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)) { placemark in
            
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
    
    func getCurrentSwitchStates() {
        switch approachingSwitcher.selectedSegmentIndex {
        case 0: alertOnArrival = true
        case 1: alertOnArrival = false
        default:
            alertOnArrival = true
        }
        
        switch singleUseSwitcher.selectedSegmentIndex {
        case 0: isRecurring = false
        case 1: isRecurring = true
        default:
            isRecurring = true
        }
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
        // Check to see if there is a location and name
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
                getCurrentSwitchStates()
                reminder.setValue(isRecurring, forKey: "isRecurring")
                reminder.setValue(alertOnArrival, forKey: "alertOnArrival")
                
                // Delete and re-add notifications
                notificationManager.removeNotification(withIdentifier: reminder.uuid)
                notificationManager.createNotification(with: reminder)
                notificationManager.getAllNotifications()
                
                // Saving the changes
                context.saveChanges()
                dismiss(animated: true, completion: nil)
            }
            
        } else {
            guard let placemark = placemark else { createAlert(withTitle: "Location needed", andDescription: "Please enter a location to save"); return }

            
            // Create location and reminder
            let location = Location.with(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude, address: placemark.name, city: placemark.locality, inContext: context)
            
            let reminder = Reminder.with(name, description: nil, alertOnArrival: alertOnArrival, isRecurring: isRecurring, creationDate: date, location: location, inContext: context)
            
            // Create notification
            notificationManager.createNotification(with: reminder)
            notificationManager.getAllNotifications()
            
            context.saveChanges()
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func mapPressed(gestureRecogniser: UIGestureRecognizer) {
        
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
        locationManager.requestLocation()
        getCurrentLocationButton.tintColor = .systemBlue
        
    }
   
    @IBAction func approachingSwitched(_ sender: Any) {
        switch approachingSwitcher.selectedSegmentIndex {
        case 0: alertOnArrival = true
        case 1: alertOnArrival = false
        default:
            alertOnArrival = true
        }
    }
    
    @IBAction func singleUseSwitched(_ sender: Any) {
        switch singleUseSwitcher.selectedSegmentIndex {
        case 0: isRecurring = false
        case 1: isRecurring = true
        default:
            alertOnArrival = true
        }
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if let reminder = editingReminder {
            notificationManager.removeNotification(withIdentifier: reminder.uuid)

            context.delete(reminder)
            context.saveChanges()
            dismiss(animated: true, completion: nil)
                        
        } else {
            print("Not Deleted")
        }
    }
}


// MARK: Extensions

extension Create_EditReminderViewController: LocationManagerDelegate {
    
    func obtainedPlacemark(_ placemark: CLPlacemark, location: CLLocation) {
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


extension Create_EditReminderViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor.systemBlue.withAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.systemBlue
            circleRenderer.lineWidth = 2
            return circleRenderer

        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

// Make keyboard dismiss when done is pressed on the keyboard
extension Create_EditReminderViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        if textField == locationTextField, let address = textField.text {
            locationManager.getLocation(from: address) { placemark in
                
                if let placemark = placemark, let location = placemark.location {
                    self.clLocation = location
                    self.placemark = placemark
                    self.addPin(at: location)

                } else {
                    textField.text = nil
                    textField.placeholder = "Location not found..."
                }
            }
        }
        
        return true
    }
}
