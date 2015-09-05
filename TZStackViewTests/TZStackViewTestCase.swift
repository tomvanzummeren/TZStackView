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

    override func setUp() {
        super.setUp()
        // Create stack views with same views
        uiStackView = UIStackView(arrangedSubviews: createTestViews())
        uiStackView.translatesAutoresizingMaskIntoConstraints = false
        tzStackView = TZStackView(arrangedSubviews: createTestViews())
        tzStackView.translatesAutoresizingMaskIntoConstraints = false

        let window = UIApplication.sharedApplication().windows[0]
        window.addSubview(uiStackView)
        window.addSubview(tzStackView)

        configureStackViews(uiStackView, tzStackView)
    }
    
    override func tearDown() {
        super.tearDown()
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
    
    // To override in subclass
    func createTestViews() -> [UIView] {
        fatalError("implement createViews()")
    }
    
    // To override in subclass
    func configureStackViews(uiStackView: UIStackView, _ tzStackView: TZStackView) {
    }
    
    func verifyConstraints(log log: Bool = false) {
        // Force constraints to be created
        uiStackView.layoutIfNeeded()
        tzStackView.layoutIfNeeded()

        if log {
            logAllConstraints()
        }
        // Assert same constraints are created
        assertSameConstraints(uiStackView.constraints, tzStackView.constraints)
        
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
    
    func assertSameConstraints(uiConstraints: [NSLayoutConstraint], _ tzConstraints: [NSLayoutConstraint]) {
        XCTAssertEqual(uiConstraints.count, tzConstraints.count, "Number of constraints")
        if uiConstraints.count != tzConstraints.count {
            return
        }
        
        for (index, uiConstraint) in uiConstraints.enumerate() {
            let tzConstraint = tzConstraints[index]
            
            let result = hasSameConstraintMetaData(uiConstraint, tzConstraint)
                && (isSameConstraint(uiConstraint, tzConstraint) || isSameConstraintFlipped(uiConstraint, tzConstraint))
            
            XCTAssertTrue(result, "Constraints at index \(index) do not match\n== EXPECTED ==\n\(uiConstraint.readableString())\n\n== ACTUAL ==\n\(tzConstraint.readableString())\n\n")
        }
    }
    
    private func hasSameConstraintMetaData(layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
        if layoutConstraint1.constant != layoutConstraint2.constant {
            return false
        }
        if layoutConstraint1.multiplier != layoutConstraint2.multiplier {
            return false
        }
        if layoutConstraint1.priority != layoutConstraint2.priority {
            if layoutConstraint1.priority < 100 || layoutConstraint1.priority > 150
                || layoutConstraint2.priority < 100 || layoutConstraint2.priority > 150 {
                    return false
            }
        }
        return true
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
        return true
    }
    
    private func isSameConstraintFlipped(layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
        if !viewsEqual(layoutConstraint1.firstItem, layoutConstraint2.secondItem) {
            return false
        }
        if !viewsEqual(layoutConstraint1.secondItem, layoutConstraint2.firstItem) {
            return false
        }
        if layoutConstraint1.firstAttribute != layoutConstraint2.secondAttribute {
            return false
        }
        if layoutConstraint1.secondAttribute != layoutConstraint2.firstAttribute {
            return false
        }
        return true
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
        if object1 is UILayoutGuide && object2 is TZSpacerView {
            return true
        }
        // Wish I could assert more accurately than this
        if object1 is TZSpacerView && object2 is UILayoutGuide {
            return true
        }
        return false
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