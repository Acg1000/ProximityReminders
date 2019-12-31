//
//  LocationManager.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/30/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import CoreLocation
import Network

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    weak var permissionsDelegate: LocationPermissionsDelegate?
    weak var locationDelegate: LocationManagerDelegate?
    private let monitor = NWPathMonitor()
    
    init(locationDelegate: LocationManagerDelegate?, permissionsDelegate: LocationPermissionsDelegate?) {
        self.locationDelegate = locationDelegate
        self.permissionsDelegate = permissionsDelegate
        super.init()
        
        manager.delegate = self
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connection works correctly")
                return
            } else {
                
                DispatchQueue.main.async {
                    locationDelegate?.failedWithError(LocationError.unableToFindLocation)
                }
            }
        }
    }
    
    
    // MARK: Authorization Functions
    static var isAuthorized: Bool {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse: return true
        default: return false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            permissionsDelegate?.authorizationSucceeded()
        } else {
            permissionsDelegate?.authorizationFailedWithStatus(status)
        }
    }
    
    func requestLocationAuthorization() throws {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .restricted || authorizationStatus == .denied {
            throw LocationError.disallowedByUser
        } else if authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else {
            return
        }
    }
    
    // MARK: Location
    func requestLocation() {
        
        // This checks to see if there is an active network connection
        let queue = DispatchQueue(label: "Network Monitor")
        monitor.start(queue: queue)
        
        do {
            try requestLocationAuthorization()

        } catch LocationError.disallowedByUser {
            locationDelegate?.failedWithError(LocationError.disallowedByUser)
        } catch LocationError.unableToFindLocation {
            locationDelegate?.failedWithError(LocationError.unableToFindLocation)
        } catch LocationError.unknownError {
            locationDelegate?.failedWithError(LocationError.unknownError)
        } catch {
            fatalError("\(error)")
        }
        
        manager.requestLocation()
    }
    
    func getPlacemark(from location: CLLocation, completionHandler: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                let placemark = placemarks?[0]
                completionHandler(placemark)

            } else {
                completionHandler(nil)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let error = error as? CLError else {
            locationDelegate?.failedWithError(.unknownError)
            return
        }
        
        switch error.code {
        case .locationUnknown: locationDelegate?.failedWithError(.unableToFindLocation)
        case .network: locationDelegate?.failedWithError(.unableToFindLocation)
        case .denied: locationDelegate?.failedWithError(.disallowedByUser)
        default: return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            locationDelegate?.failedWithError(.unableToFindLocation)
            return
        }
                
        getPlacemark(from: location) { placemark in
            guard let placemark = placemark else { return }
            
            if let location = placemark.location {
                self.locationDelegate?.obtainedPlacemark(placemark, location: location)

            } else {
                self.locationDelegate?.failedWithError(.unableToFindLocation)
                
            }
        }
    }
}

// MARK: Protocol and Enums
enum LocationError: Error {
    case unknownError
    case disallowedByUser
    case unableToFindLocation
}

protocol LocationPermissionsDelegate: class {
    func authorizationSucceeded()
    func authorizationFailedWithStatus(_ status: CLAuthorizationStatus)
}

protocol LocationManagerDelegate: class {
    func obtainedPlacemark(_ placemark: CLPlacemark, location: CLLocation)
    func failedWithError(_ error: LocationError)
}
