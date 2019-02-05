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

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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

        let window = UIApplication.shared.windows[0]
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
    func configureStackViews(_ uiStackView: UIStackView, _ tzStackView: TZStackView) {
    }
    
    func verifyConstraints(log: Bool = false) {
        // Force constraints to be created
        uiStackView.layoutIfNeeded()
        tzStackView.layoutIfNeeded()

        if log {
            logAllConstraints()
        }
        // Assert same constraints are created
        assertSameConstraints(uiStackView.constraints, tzStackView.constraints)
        
        for (index, uiArrangedSubview) in uiStackView.arrangedSubviews.enumerated() {
            let tzArrangedSubview = tzStackView.arrangedSubviews[index]
            
            let uiConstraints = nonContentSizeLayoutConstraints(uiArrangedSubview)
            let tzConstraints = nonContentSizeLayoutConstraints(tzArrangedSubview)
            
            // Assert same constraints are created
            assertSameConstraints(uiConstraints, tzConstraints)
        }
    }
    
    fileprivate func nonContentSizeLayoutConstraints(_ view: UIView) -> [NSLayoutConstraint] {
        return view.constraints.filter({ "\(type(of: $0))" != "NSContentSizeLayoutConstraint" })
    }
    
    func assertSameConstraints(_ uiConstraints: [NSLayoutConstraint], _ tzConstraints: [NSLayoutConstraint]) {
        XCTAssertEqual(uiConstraints.count, tzConstraints.count, "Number of constraints")
        if uiConstraints.count != tzConstraints.count {
            return
        }
        
        for (index, uiConstraint) in uiConstraints.enumerated() {
            let tzConstraint = tzConstraints[index]
            
            let result = hasSameConstraintMetaData(uiConstraint, tzConstraint)
                && (isSameConstraint(uiConstraint, tzConstraint) || isSameConstraintFlipped(uiConstraint, tzConstraint))
            
            XCTAssertTrue(result, "Constraints at index \(index) do not match\n== EXPECTED ==\n\(uiConstraint.readableString())\n\n== ACTUAL ==\n\(tzConstraint.readableString())\n\n")
        }
    }
    
    fileprivate func hasSameConstraintMetaData(_ layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
        if layoutConstraint1.constant != layoutConstraint2.constant {
            return false
        }
        if layoutConstraint1.multiplier != layoutConstraint2.multiplier {
            return false
        }
        if layoutConstraint1.priority != layoutConstraint2.priority {
            if layoutConstraint1.priority.rawValue < 100.0 || layoutConstraint1.priority.rawValue > 150.0
                || layoutConstraint2.priority.rawValue < 100.0 || layoutConstraint2.priority.rawValue > 150.0 {
                    return false
            }
        }
        return true
    }
    
    fileprivate func isSameConstraint(_ layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
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
    
    fileprivate func isSameConstraintFlipped(_ layoutConstraint1: NSLayoutConstraint, _ layoutConstraint2: NSLayoutConstraint) -> Bool {
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

    fileprivate func printConstraints(_ constraints: [NSLayoutConstraint]) {
        for constraint in constraints {
            print(constraint.readableString())
        }
    }
    
    fileprivate func viewsEqual(_ object1: AnyObject?, _ object2: AnyObject?) -> Bool {
        if object1 == nil && object2 == nil {
            return true
        }
        if let view1 = object1 as? UIView, let view2 = object2 as? UIView, view1.frame == view2.frame && view1.description == view2.description {
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

    func assertSameOrder(_ uiTestViews: [TestView], _ tzTestViews: [TestView]) {
        for (index, uiTestView) in uiTestViews.enumerated() {
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
