//
//  DateExtension.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 10..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
