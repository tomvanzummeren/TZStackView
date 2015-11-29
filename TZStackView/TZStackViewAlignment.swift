//
//  TZStackViewAlignment.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 15/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation

/* Alignment—the layout transverse to the stacking axis.
*/
@objc public enum TZStackViewAlignment : Int {
    
    /* Align the leading and trailing edges of vertically stacked items
    or the top and bottom edges of horizontally stacked items tightly to the container.
    */
    case Fill = 0
    
    /* Align the leading edges of vertically stacked items
    or the top edges of horizontally stacked items tightly to the relevant edge
    of the container
    */
    case Leading = 1
    public static let Top: TZStackViewAlignment = .Leading
    case FirstBaseline = 2 // Valid for horizontal axis only
    
    /* Center the items in a vertical stack horizontally
    or the items in a horizontal stack vertically
    */
    case Center = 3
    
    /* Align the trailing edges of vertically stacked items
    or the bottom edges of horizontally stacked items tightly to the relevant
    edge of the container
    */
    case Trailing = 4
    public static let Bottom: TZStackViewAlignment = .Trailing
//    case LastBaseline = 5 // Valid for horizontal axis only
}
