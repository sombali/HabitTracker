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

@objc(Habit)
public class Habit: NSManagedObject {

    var dateString: String {
        guard let date = date as Date? else {
            return "No date"
        }
        
        let formatter = DateFormatter()
        return formatter.string(from: date)
        
    }
}
