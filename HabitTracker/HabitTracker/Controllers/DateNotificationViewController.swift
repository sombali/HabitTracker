//
//  DateNotificationViewController.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 16..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit
import UserNotifications

class DateNotificationViewController: UIViewController {
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var text: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.setValue(UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0), forKeyPath: "textColor")
        
        requestNotificationAuthorization()
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init([.alert, .badge, .sound])
        userNotificationCenter.requestAuthorization(options: authOptions) { success, error  in
            if let _ = error {
                self.dismiss(animated: true)
            }
        }
    }
    
    func sendNotification() {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "You have a habit to do"
        if let text = text {
            notificationContent.body = text
        }
        
        var dateComponent = DateComponents()
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: datePicker.date)
        let minute = calendar.component(.minute, from: datePicker.date)
        dateComponent.hour = hour
        dateComponent.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        userNotificationCenter.add(request) { error in
            if let error = error {
                print("Notification error: ", error)
            }
        }
        
    }
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        sendNotification()
        self.dismiss(animated: true)
    }
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
