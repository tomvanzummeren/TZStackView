//
//  NSLayoutConstraintExtension.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    func readableString() -> String {
        return "\(self.dynamicType)(\n  item1: \(unwrap(firstItem)), firstAttribute: \(toString(firstAttribute))\n  relation: \(toString(relation))\n  secondItem: \(unwrap(secondItem)), secondAttribute: \(toString(secondAttribute))\n  constant: \(constant)\n  multiplier: \(multiplier)\n  priority: \(priority)\n)"
    }
    
    private func unwrap(object: AnyObject?) -> String {
        if let object = object {
            return "\(object)"
        }
        return "nil"
    }
    
    private func toString(relation: NSLayoutRelation) -> String {
        switch relation {
        case .LessThanOrEqual: return "LessThanOrEqual"
        case .Equal: return "Equal"
        case .GreaterThanOrEqual: return "GreaterThanOrEqual"
        }
    }
    
    private func toString(attribute: NSLayoutAttribute) -> String {
        switch attribute {
        case .Left: return "Left"
        case .Right: return "Right"
        case .Top: return "Top"
        case .Bottom: return "Bottom"
        case .Leading: return "Leading"
        case .Trailing: return "Trailing"
        case .Width: return "Width"
        case .Height: return "Height"
        case .CenterX: return "CenterX"
        case .CenterY: return "CenterY"
        case .Baseline: return "Baseline"
        case .FirstBaseline: return "FirstBaseline"
        case .NotAnAttribute: return "NotAnAttribute"
        case .LeftMargin: return "LeftMargin"
        case .RightMargin: return "RightMargin"
        case .TopMargin: return "TopMargin"
        case .BottomMargin: return "BottomMargin"
        case .LeadingMargin: return "LeadingMargin"
        case .TrailingMargin: return "TrailingMargin"
        case .CenterXWithinMargins: return "CenterXWithinMargins"
        case .CenterYWithinMargins: return "CenterYWithinMargins"
        }
    }
}