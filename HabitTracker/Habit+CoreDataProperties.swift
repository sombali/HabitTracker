//
//  Habit+CoreDataProperties.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 28..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//
//

import Foundation
import CoreData


extension Habit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }

    @NSManaged public var date: Date?
    @NSManaged public var dayOfMonth: Int16
    @NSManaged public var dayOfWeek: Int16
    @NSManaged public var name: String?
    @NSManaged public var period: Int16
    @NSManaged public var streak: Int64
    @NSManaged public var timeOfDay: Int16
    @NSManaged public var checkedForToday: Bool

}
