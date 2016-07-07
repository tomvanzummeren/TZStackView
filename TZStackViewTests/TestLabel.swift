//
//  TestLabel.swift
//  TZStackView
//
//  Created by CosynPa on 12/12/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation
import UIKit

class TestLabel: UILabel {
    var identifier: String = ""
    
    init(identifier: String) {
        self.identifier = identifier
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

func ==(lhs: TestLabel, rhs: TestLabel) -> Bool {
    return lhs.identifier == rhs.identifier
}
