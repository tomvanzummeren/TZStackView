//
//  StackViewTest.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 12/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation
import XCTest

import TZStackView

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ), dispatch_get_main_queue(), closure)
}

class TZStackViewTestCase: XCTestCase {
    
    var uiStackView: UIStackView!
    var tzStackView: TZStackView!

    func recreateStackViews(createSubviews: () -> [UIView]) {
        // clean old views otherwise some old spacer views and constraints are left
        if uiStackView != nil {
            uiStackView.removeFromSuperview()
        }
        
        if tzStackView != nil {
            tzStackView.removeFromSuperview()
        }
        
        // Create stack views with same views
        uiStackView = UIStackView(arrangedSubviews: createSubviews())
        uiStackView.translatesAutoresizingMaskIntoConstraints = false
        tzStackView = TZStackView(arrangedSubviews: createSubviews())
        tzStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let window = UIApplication.sharedApplication().windows[0]
        window.addSubview(uiStackView)
        window.addSubview(tzStackView)
    }
    
    func logAllConstraints() {
        print("================= UISTACKVIEW (\(uiStackView.constraints.count)) =================")
        print("subviews: \(uiStackView.subviews)")
        printConstraints(uiStackView.constraints)
        print("")
        for subview in uiStackView.arrangedSubviews {
            print("\(subview):")
            printConstraints(nonContentSizeLayoutConstraints(subview))
        }

        print("================= TZSTACKVIEW (\(tzStackView.constraints.count)) =================")
        print("subviews: \(tzStackView.subviews)")
        printConstraints(tzStackView.constraints)
        print("")
        for subview in tzStackView.arrangedSubviews {
            print("\(subview):")
            printConstraints(nonContentSizeLayoutConstraints(subview))
        }
    }
    
    func verifyConstraints(log log: Bool = false) {
        // Force constraints to be created
        uiStackView.setNeedsUpdateConstraints()
        uiStackView.updateConstraintsIfNeeded()
        uiStackView.setNeedsLayout()
        uiStackView.layoutIfNeeded()
        
        tzStackView.setNeedsUpdateConstraints()
        tzStackView.updateConstraintsIfNeeded()
        tzStackView.setNeedsLayout()
        tzStackView.layoutIfNeeded()

        if log {
            logAllConstraints()
        }
        // Assert same constraints are created
        assertSameConstraints(nonMarginsLayoutConstraints(uiStackView), nonMarginsLayoutConstraints(tzStackView))
        
        for (index, uiArrangedSubview) in uiStackView.arrangedSubviews.enumerate() {
            let tzArrangedSubview = tzStackView.arrangedSubviews[index]
            
            let uiConstraints = nonContentSizeLayoutConstraints(uiArrangedSubview)
            let tzConstraints = nonContentSizeLayoutConstraints(tzArrangedSubview)
            
            // Assert same constraints are created
            assertSameConstraints(uiConstraints, tzConstraints)
        }
    }
    
    private func nonContentSizeLayoutConstraints(view: UIView) -> [NSLayoutConstraint] {
        return view.constraints.filter({ "\($0.dynamicType)" != "NSContentSizeLayoutConstraint" })
    }
    
    private func nonMarginsLayoutConstraints(view: UIView) -> [NSLayoutConstraint] {
        return view.constraints.filter { aConstraint in
            if let identifier = aConstraint.identifier {
                return !identifier.hasSuffix("Margin-guide-constraint")
            } else {
                return true
            }
        }
    }
    
    func assertSameConstraints(uiConstraints: [NSLayoutConstraint], _ tzConstraints: [NSLayoutConstraint]) {
        func getGuides(constraints: [NSLayoutConstraint]) -> [NSObject] {
            var result = Set<NSObject>()
            
            for aConstraint in constraints {
                let firstItem = aConstraint.firstItem
                if firstItem is TZSpacerView || firstItem is UILayoutGuide {
                    result.insert(firstItem as! NSObject)
                }
                
                if let secondItem = aConstraint.secondItem where secondItem is TZSpacerView || secondItem is UILayoutGuide {
                    result.insert(secondItem as! NSObject)
                }
            }
            
            return Array(result)
        }
        
        let uiGuides = getGuides(uiConstraints)
        let tzGuides = getGuides(tzConstraints)
        
        XCTAssertEqual(uiGuides.count, tzGuides.count, "Number of layout guides")

        let uiGrouped = Array(uiConstraints.enumerate()).groupBy{ (index, constraint) in constraint.identifier ?? "" }
        let tzGrouped = Array(tzConstraints.enumerate()).groupBy{ (index, constraint) in constraint.identifier ?? "" }
        
        identifierLoop: for (identifier, uiGroup) in uiGrouped {
            let tzIdentifier = identifier.hasPrefix("UI") ? "TZ" + String(identifier.characters.dropFirst("UI".characters.count)) : identifier
            if let tzGroup = tzGrouped[tzIdentifier] {
                XCTAssertEqual(uiGroup.count, tzGroup.count, "Number of constraints with identifier \(identifier)")
                guard uiGroup.count == tzGroup.count else {
                    continue
                }
               
                var tzGroupLeft = tzGroup
                for (index, uiConstraint) in uiGroup { // note, the index is the index of uiConstraints, not uiGroup
                    let tzIndex = tzGroupLeft.indexOf { (_, tzConstraint) in
                        return isSameConstraint(uiConstraint, tzConstraint) || isSameConstraintFlipped(uiConstraint, tzConstraint)
                    }
                    
                    if let tzIndex = tzIndex {
                        tzGroupLeft.removeAtIndex(tzIndex)
                    } else {
                        XCTAssert(false, "Constraints at index \(index) do not match\n== EXPECTED ==\n\(uiConstraint.readableString())\n\n== POSSIBLE ACTUAL ==\n\(tzConstraints[index].readableString())\n\n")
                        continue identifierLoop
                    }
                }
            } else {
                XCTAssert(false, "EXPECTED constraints with identifier \(identifier) have no match")
            }
        }
        
        for (identifier, _) in tzGrouped {
            let uiIdentifier = identifier.hasPrefix("TZ") ? "UI" + String(identifier.characters.dropFirst("TZ".characters.count)) : identifier
            if let _ = uiGrouped[uiIdentifier] {
                // nothing to check unless UI constraints have two same constraints
            } else {
                XCTAssert(false, "UNEXPECTED extra constraints with identifier \(identifier)")
            }
        }
    }
    
    private func isSameConstraint(layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
        if !viewsEqual(layoutConstraint1.firstItem, layoutConstraint2.firstItem) {
            return false
        }
        if !viewsEqual(layoutConstraint1.secondItem, layoutConstraint2.secondItem) {
            return false
        }
        if layoutConstraint1.firstAttribute != layoutConstraint2.firstAttribute {
            return false
        }
        if layoutConstraint1.secondAttribute != layoutConstraint2.secondAttribute {
            return false
        }
        if layoutConstraint1.relation != layoutConstraint2.relation {
            return false
        }
        if fabs(layoutConstraint1.multiplier - layoutConstraint2.multiplier) > 0.001 {
            return false
        }
        if fabs(layoutConstraint1.constant - layoutConstraint2.constant) > 0.001 {
            return false
        }
        if fabs(layoutConstraint1.priority - layoutConstraint2.priority) > 0.001 {
            return false
        }
        if !isSameIdentifier(layoutConstraint1.identifier, layoutConstraint2.identifier) {
            return false
        }
        return true
    }
    
    private func isSameConstraintFlipped(layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
        func flipRelation(relation: NSLayoutRelation) -> NSLayoutRelation {
            switch relation {
            case .Equal:
                return .Equal
            case .GreaterThanOrEqual:
                return .LessThanOrEqual
            case .LessThanOrEqual:
                return .GreaterThanOrEqual
            }
        }

        func flipConstraint(constraint: NSLayoutConstraint) -> NSLayoutConstraint {
            guard constraint.multiplier != 0 else {
                return constraint
            }
            
            guard let secondItem = constraint.secondItem else {
                return constraint
            }
            
            let flipped = NSLayoutConstraint(item: secondItem,
                attribute: constraint.secondAttribute,
                relatedBy: constraint.multiplier > 0 ? flipRelation(constraint.relation) : constraint.relation,
                toItem: constraint.firstItem,
                attribute: constraint.firstAttribute,
                multiplier: 1 / constraint.multiplier,
                constant: -constraint.constant / constraint.multiplier)
            
            flipped.identifier = constraint.identifier
            flipped.priority = constraint.priority
            
            return flipped
        }
        
        return isSameConstraint(layoutConstraint1, flipConstraint(layoutConstraint2))
    }

    private func printConstraints(constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            print(constraint.readableString())
        }
    }
    
    private func viewsEqual(object1: AnyObject?, _ object2: AnyObject?) -> Bool {
        if object1 == nil && object2 == nil {
            return true
        }
        if let view1 = object1 as? UIView, view2 = object2 as? UIView where view1 == view2 {
            return true
        }
        if object1 is UIStackView && object2 is TZStackView {
            return true
        }
        if object1 is TZStackView && object2 is UIStackView {
            return true
        }
        // Wish I could assert more accurately than this
        if let object1 = object1 as? UILayoutGuide, object2 = object2 as? TZSpacerView
            where isSameIdentifier(object1.identifier, object2.identifier) {
            return true
        }
        // Wish I could assert more accurately than this
        if let object1 = object1 as? TZSpacerView, object2 = object2 as? UILayoutGuide
            where isSameIdentifier(object1.identifier, object2.identifier) {
            return true
        }
        return false
    }
    
    private func isSameIdentifier(identifier1: String, _ identifier2: String) -> Bool {
        func hasPrefix(str: String) -> Bool {
            return str.hasPrefix("UI") || str.hasPrefix("TZ")
        }
        
        func dropPrefix(str: String) -> String {
            return String(str.characters.dropFirst("UI".characters.count))
        }
        
        return identifier1 == identifier2 || (hasPrefix(identifier1) && hasPrefix(identifier2) && dropPrefix(identifier1) == dropPrefix(identifier2))
    }
    
    private func isSameIdentifier(identifier1: String?, _ identifier2: String?) -> Bool {
        switch (identifier1, identifier2) {
        case (nil, nil):
            return true
        case (.Some, nil), (nil, .Some):
            return false
        case (.Some(let id1), .Some(let id2)):
            return isSameIdentifier(id1, id2)
        }
    }

    func assertSameOrder(uiTestViews: [TestView], _ tzTestViews: [TestView]) {
        for (index, uiTestView) in uiTestViews.enumerate() {
            let tzTestView = tzTestViews[index]

            let result = uiTestView.index == tzTestView.index

            XCTAssertTrue(result, "Views at index \(index) do not match\n== EXPECTED ==\n\(uiTestView.description)\n\n== ACTUAL ==\n\(tzTestView.description)\n\n")
        }
    }

    func verifyArrangedSubviewConsistency() {
        XCTAssertEqual(uiStackView.arrangedSubviews.count, tzStackView.arrangedSubviews.count, "Number of arranged subviews")

        let uiArrangedSubviews = uiStackView.arrangedSubviews as! [TestView]
        let tzArrangedSubviews = tzStackView.arrangedSubviews as! [TestView]

        assertSameOrder(uiArrangedSubviews, tzArrangedSubviews)

        for tzTestView in tzArrangedSubviews {
            let result = tzStackView.subviews.contains(tzTestView)

            XCTAssertTrue(result, "\(tzTestView.description) is in arranged subviews but is not actually a subview")
        }
    }
}