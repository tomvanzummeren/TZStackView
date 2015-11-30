//
//  TZStackViewAlignment.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 15/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation

@objc public enum TZStackViewAlignment: Int {
    /* Align the leading and trailing edges of vertically stacked items
    or the top and bottom edges of horizontally stacked items tightly to the container.
    */
    case Fill
    
    /* Align the leading edges of vertically stacked items
    or the top edges of horizontally stacked items tightly to the relevant edge
    of the container
    */
    case Leading
    public static var Top: TZStackViewAlignment {
        get {
            return .Leading
        }
    }
    case FirstBaseline // Valid for horizontal axis only
    
    /* Center the items in a vertical stack horizontally
    or the items in a horizontal stack vertically
    */
    case Center
    
    /* Align the trailing edges of vertically stacked items
    or the bottom edges of horizontally stacked items tightly to the relevant
    edge of the container
    */
    case Trailing
    public static var Bottom: TZStackViewAlignment { get {
            return .Trailing
        }
    }
    case LastBaseline // Valid for horizontal axis only
}
