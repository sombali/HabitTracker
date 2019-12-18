//
//  CenteredSegue.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 18..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import Foundation
import SwiftMessages

class CenteredSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .centered)
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
        messageView.configureNoDropShadow()
    }
}
