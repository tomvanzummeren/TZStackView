//
//  TZStackViewAlignment.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 15/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation

@objc public enum TZStackViewAlignment: Int {
    case Fill             = 0
    case Leading          = 1
    case FirstBaseline    = 2
    case Center           = 3
    case Trailing         = 4
    case LastBaseline     = 5
    public static var Top : TZStackViewAlignment { return .Leading }
    public static var Bottom : TZStackViewAlignment { return .Trailing }
}
