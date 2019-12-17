//
//  Habit+CoreDataClass.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 09..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//
//

import Foundation
import CoreData


public class Habit: NSManagedObject {

    var dateString: String {
        guard let date = date as Date? else {
            return "No date"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var periodValue: Period? {
        get {
            return Period(rawValue: period)!
        }
        set {
            self.period = newValue!.rawValue
        }
    }
    
    var timeOfDayValue: TimeOfDay? {
        get {
            return TimeOfDay(rawValue: timeOfDay)!
        }
        set {
            self.timeOfDay = newValue!.rawValue
        }
    }
    
}
