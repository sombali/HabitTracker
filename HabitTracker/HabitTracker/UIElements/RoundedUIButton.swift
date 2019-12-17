//
//  RoundedUIButton.swift
//  HabitTracker
//
//  Created by Somogyi Balázs on 2019. 12. 09..
//  Copyright © 2019. Somogyi Balázs. All rights reserved.
//

import UIKit

class RoundedUIButton: UIButton {
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        self.layer.cornerRadius = 10
//        //self.backgroundColor = UIColor.opaqueSeparator
//    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.layer.cornerRadius = 6
        //self.backgroundColor = UIColor.opaqueSeparator
    }

}
