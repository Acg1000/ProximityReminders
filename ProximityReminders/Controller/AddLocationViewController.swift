//
//  AddLocationViewController.swift
//  ProximityReminders
//
//  Created by Andrew Graves on 12/30/19.
//  Copyright © 2019 Andrew Graves. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var locationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
