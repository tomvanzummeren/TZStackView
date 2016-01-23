//
//  TZStackViewTests.swift
//  TZStackViewTests
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit
import XCTest

import TZStackView

class TZStackViewTests: TZStackViewTestCase {
    
    func createTestViews() -> [UIView] {
        var views = [UIView]()
        for i in 0 ..< 5 {
            views.append(TestView(index: i, size: CGSize(width: 100 * (i + 1), height: 100 * (i + 1))))
        }
        
        return views
    }
    
    func testSameConstraints() {
        let margins = [false, true]
        let axes = [
            (UILayoutConstraintAxis.Horizontal, "Horizontal"),
            (.Vertical, "Vertical")
        ]
        let distributions = [
            (UIStackViewDistribution.Fill, TZStackViewDistribution.Fill, "Fill"),
            (.FillEqually, .FillEqually, "FillEqually"),
            (.FillProportionally, .FillProportionally, "FillProportionally"),
            (.EqualSpacing, .EqualSpacing, "EqualSpacing"),
            (.EqualCentering, .EqualCentering, "EqualCentering")
        ]
        let alignments = [
            (UIStackViewAlignment.Fill, TZStackViewAlignment.Fill, "Fill"),
            (.Leading, .Leading, "Leading"),
            (UIStackViewAlignment.Top, TZStackViewAlignment.Top, "Top"),
            (.FirstBaseline, .FirstBaseline, "FirstBaseline"),
            (.Center, .Center, "Center"),
            (.Trailing, .Trailing, "Trailing"),
            (UIStackViewAlignment.Bottom, TZStackViewAlignment.Bottom, "Bottom"),
            (.LastBaseline, .LastBaseline, "LastBaseline"),
        ]
        let spacings = [CGFloat(10)]
        let subviews = [createTestViews]
        
        let cases = margins * axes * distributions * alignments * spacings * subviews

        for aCase in cases {
            let (tuple5, subview) = aCase
            let (tuple4, spacing) = tuple5
            let (tuple3, aligment) = tuple4
            let (tuple2, distribution) = tuple3
            let (tuple1, axis) = tuple2
            let margin = tuple1
            
            print("Test for layoutMarginsRelativeArrangement=\(margin), axis=\(axis.1), distribution=\(distribution.2), aligment=\(aligment.2), spacing=\(spacing)\n")
            
            recreateStackViews(subview)
            
            uiStackView.layoutMarginsRelativeArrangement = margin
            tzStackView.layoutMarginsRelativeArrangement = margin
            
            uiStackView.axis = axis.0
            tzStackView.axis = axis.0
            
            uiStackView.distribution = distribution.0
            tzStackView.distribution = distribution.1
            
            uiStackView.alignment = aligment.0
            tzStackView.alignment = aligment.1
            
            uiStackView.spacing = spacing
            tzStackView.spacing = spacing
            
            verifyConstraints()
        }
    }
    
    func testFillHorizontalFill() {
        recreateStackViews(createTestViews)
        
        uiStackView.axis = .Horizontal
        uiStackView.distribution = .Fill
        uiStackView.alignment = .Fill
        tzStackView.axis = .Horizontal
        tzStackView.distribution = .Fill
        tzStackView.alignment = .Fill
        
        uiStackView.spacing = 10
        tzStackView.spacing = 10
        
        verifyConstraints()
    }

    // MARK: - Maintaining Consistency Between the Arranged Views and Subviews
    // https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/#//apple_ref/doc/uid/TP40015256-CH1-SW29
    func testConsistencyWhenAddingArrangedSubview() {
        recreateStackViews(createTestViews)
        
        let uiTestView = TestView(index: -1, size: CGSize(width: 100, height: 100))
        uiStackView.addArrangedSubview(uiTestView)

        let tzTestView = TestView(index: -1, size: CGSize(width: 100, height: 100))
        tzStackView.addArrangedSubview(tzTestView)

        verifyArrangedSubviewConsistency()
    }

    func testConsistencyWhenInsertingArrangedSubview() {
        recreateStackViews(createTestViews)
        
        let uiTestView = TestView(index: -1, size: CGSize(width: 100, height: 100))
        uiStackView.insertArrangedSubview(uiTestView, atIndex: 0)

        let tzTestView = TestView(index: -1, size: CGSize(width: 100, height: 100))
        tzStackView.insertArrangedSubview(tzTestView, atIndex: 0)

        verifyArrangedSubviewConsistency()
    }

    func testConsistencyWhenRemovingArrangedSubview() {
        recreateStackViews(createTestViews)
        
        let uiTestView = uiStackView.arrangedSubviews.last
        uiStackView.removeArrangedSubview(uiTestView!)

        let tzTestView = tzStackView.arrangedSubviews.last
        tzStackView.removeArrangedSubview(tzTestView!)

        verifyArrangedSubviewConsistency()
    }

    func testConsistencyWhenRemovingSubview() {
        recreateStackViews(createTestViews)
        
        let uiTestView = uiStackView.arrangedSubviews.last
        uiTestView!.removeFromSuperview()

        let tzTestView = tzStackView.arrangedSubviews.last
        tzTestView!.removeFromSuperview()

        verifyArrangedSubviewConsistency()
    }
}
