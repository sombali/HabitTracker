//
//  Habit+CoreDataProperties.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 09..
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
    @NSManaged public var name: String?
    @NSManaged public var period: Int16
    @NSManaged public var timeOfDay: Int16
    @NSManaged public var streak: Int64

}
