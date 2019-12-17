//
//  BottomCardSegue.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 16..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import Foundation
import SwiftMessages

class BottomCardSegue: SwiftMessagesSegue {
    override public init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        configure(layout: .bottomCard)
        dimMode = .blur(style: .dark, alpha: 0.9, interactive: true)
        messageView.configureNoDropShadow()
    }
}
