//
//  LocationNotificationViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 17..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit
import MapKit

class LocationNotificationViewController: UIViewController {
    
    private let userNotificationCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    private let geocoder = CLGeocoder()
    private let locationManager = CLLocationManager()

    private var coordinate: CLLocationCoordinate2D?
    private var annotation: MKPointAnnotation?
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressTextField.textColor = UIColor(red:0.03, green:0.85, blue:0.84, alpha:1.0)

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .denied:
            doneButton.isEnabled = false
            addressTextField.isEnabled = false
            return
        case .restricted:
            doneButton.isEnabled = false
            addressTextField.isEnabled = false
            return
        case .authorizedWhenInUse, .authorizedAlways:
            doneButton.isEnabled = true
            print("authorized")
            addressTextField.becomeFirstResponder()
            addressTextField.isEnabled = true
          
        default:
            return
        }
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    @IBAction func searchButtonTapped(_ sender: Any) {
        addressTextField.resignFirstResponder()
        
        let ws = CharacterSet.whitespacesAndNewlines
        guard let trimmed = addressTextField.text?.trimmingCharacters(in: ws), !trimmed.isEmpty else {
            return
        }
        
        showAddressOnMap(address: trimmed)
    }
    
    private func showAddressOnMap(address: String) {
      geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
        guard let self = self else { return }

        guard error == nil else {
            return
        }

        guard let placemark = placemarks?.first,
            let coordinate = placemark.location?.coordinate else {
                return
        }

        self.coordinate = coordinate

        if let annotation = self.annotation {
            self.mapView.removeAnnotation(annotation)
        }

        self.annotation = MKPointAnnotation()
        self.annotation!.coordinate = coordinate

        if let thoroughfare = placemark.thoroughfare {
          if let subThoroughfare = placemark.subThoroughfare {
            self.annotation!.title = "\(subThoroughfare) \(thoroughfare)"
          } else {
            self.annotation!.title = thoroughfare
          }
        } else {
          self.annotation!.title = address
        }

        self.mapView.addAnnotation(self.annotation!)

        let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.mapView.setRegion(viewRegion, animated: true)
      }
    }
    
    func sendNotification() {
        guard let coordinate = coordinate else {
             return
        }
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "You reached \(annotation?.title)"
        if let text = text {
            notificationContent.body = text
        }

        let region = CLCircularRegion(center: coordinate, radius: 100, identifier: UUID().uuidString)
        region.notifyOnEntry = true
        
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification error: ", error)
            }
        }
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        sendNotification()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationNotificationViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    let authorized = status == .authorizedWhenInUse

    if authorized {
        addressTextField.becomeFirstResponder()
    }
  }
}
