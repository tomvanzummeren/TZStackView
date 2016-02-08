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
    func createTestViewWithHiddenFuncs() -> [(createViewsFunc: () -> [UIView], description: String)] {
        let viewsCount = 3
        
        let hiddenOptions = [[Bool]](count: viewsCount, repeatedValue: [false, true])
            .reduce([[]], combine: *+)
        
        return hiddenOptions.map { anHiddenOption -> (createViewsFunc: () -> [UIView], description: String) in
            let createViewFunc = { () -> [UIView] in
                let views = anHiddenOption.enumerate().map { (viewIndex, hidden) -> UIView in
                    let aView = TestView(index: viewIndex, size: CGSize(width: 100 * (viewIndex + 1), height: 100 * (viewIndex + 1)))
                    aView.hidden = hidden
                    
                    return aView
                }
                return views
            }
            
            let description = "hidden:\(anHiddenOption)"
            
            return (createViewFunc, description)
        }
    }
    
    func createTestLabelFuncs() -> [(createViewsFunc: () -> [UIView], description: String)] {
        let labelsCount = 3
        
        let numberOfLinesOptions = [[Int]](count: labelsCount, repeatedValue: [1, 0])
            .reduce([[]], combine: *+)
        
        return numberOfLinesOptions.map { anOptions -> (createViewsFunc: () -> [UIView], description: String) in
            let createViewFunc = { () -> [UIView] in
                let labels = anOptions.enumerate().map { (viewIndex, numberOfLines) -> UILabel in
                    let label = TestLabel(identifier: String(viewIndex))
                    
                    let text = String(count: viewIndex + 1, repeatedValue: Character("a"))
                    label.text = text
                    
                    label.numberOfLines = numberOfLines
                    
                    return label
                }
                return labels
            }
            
            let description = "numberOfLines:\(anOptions)"
            
            return (createViewFunc, description)
        }
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
        let subviews = [(createViewsFunc: createTestViews, description: "")]
            + createTestViewWithHiddenFuncs()
            + createTestLabelFuncs()
        
        let cases = margins * axes * distributions * alignments * spacings * subviews

        for aCase in cases {
            let (tuple5, subview) = aCase
            let (tuple4, spacing) = tuple5
            let (tuple3, aligment) = tuple4
            let (tuple2, distribution) = tuple3
            let (tuple1, axis) = tuple2
            let margin = tuple1
            
            print("Test for layoutMarginsRelativeArrangement=\(margin), axis=\(axis.1), distribution=\(distribution.2), aligment=\(aligment.2), spacing=\(spacing)\n, views=\(subview.1)")
            
            recreateStackViews(subview.0)
            
            uiStackView.layoutMargins = UIEdgeInsets()
            tzStackView.layoutMargins = UIEdgeInsets()
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
    
    func createVariousIntrinsicSizeViewFuncs() -> [(createViewsFunc: () -> [UIView], description: String)] {
        enum Option: CustomStringConvertible {
            case Hidden
            case Length(CGFloat)
            
            var description: String {
                switch self {
                case .Hidden:
                    return "hidden"
                case .Length(let length):
                    return String(length)
                }
            }
        }
        
        let lengths = [UIViewNoIntrinsicMetric] + [0, 1] + Array(CGFloat(5).stride(through: 25, by: 5))
        let possibleOptions = lengths
            .map { length in Option.Length(length) }
            + [Option.Hidden]
        
        return (0 ... 3).flatMap { viewCount -> [(createViewsFunc: () -> [UIView], description: String)] in
            let sizeAndHiddenOptions = [[Option]](count: viewCount, repeatedValue: possibleOptions)
                .reduce([[]], combine: *+)
            
            return sizeAndHiddenOptions.map { anOptions -> (createViewsFunc: () -> [UIView], description: String) in
                let createViewFunc = { () -> [UIView] in
                    let views = anOptions.enumerate().map { (viewIndex, oneViewOption) -> UIView in
                        let view: TestView
                        switch oneViewOption {
                        case .Hidden:
                            view = TestView(index: viewIndex, size: CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric))
                            view.hidden = true
                        case .Length(let length):
                            view = TestView(index: viewIndex, size: CGSize(width: length, height: length))
                        }
                        
                        return view
                    }
                    return views
                }
                
                let description = "size and hidden:\(anOptions)"
                
                return (createViewFunc, description)
            }
        }
    }
    
    func testFillPropertionally() {
        let margins = [false, true]
        let subviews = createVariousIntrinsicSizeViewFuncs() + createTestLabelFuncs()
        
        let cases = margins * subviews
        
        for aCase in cases {
            let (tuple1, subview) = aCase
            let margin = tuple1
            
            print("Test for layoutMarginsRelativeArrangement=\(margin), views=\(subview.1)")
            
            recreateStackViews(subview.0)
            
            uiStackView.layoutMargins = UIEdgeInsets()
            tzStackView.layoutMargins = UIEdgeInsets()
            uiStackView.layoutMarginsRelativeArrangement = margin
            tzStackView.layoutMarginsRelativeArrangement = margin
            
            uiStackView.axis = .Horizontal
            tzStackView.axis = .Horizontal
            
            uiStackView.distribution = .FillProportionally
            tzStackView.distribution = .FillProportionally
            
            uiStackView.alignment = .Fill
            tzStackView.alignment = .Fill
            
            uiStackView.spacing = 10
            tzStackView.spacing = 10
            
            verifyConstraints()
        }
    }

    func createTestViews() -> [UIView] {
        var views = [UIView]()
        for i in 0 ..< 5 {
            views.append(TestView(index: i, size: CGSize(width: 100 * (i + 1), height: 100 * (i + 1))))
        }
        
        //    views[0].hidden = true
        //    views[1].hidden = true
        //    views[2].hidden = true
        //    views[3].hidden = true
        //    views[4].hidden = true
        
        return views
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
