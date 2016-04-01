//
//  ViewController.swift
//  TZStackView-Example
//
//  Created by Tom van Zummeren on 20/06/15.
//  Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

import TZStackView

class ViewController: UIViewController {
    //MARK: - Properties
    //--------------------------------------------------------------------------
    var tzStackView: TZStackView!

    let resetButton = UIButton(type: .System)
    let instructionLabel = UILabel()

    var axisSegmentedControl: UISegmentedControl!
    var alignmentSegmentedControl: UISegmentedControl!
    var distributionSegmentedControl: UISegmentedControl!

    //MARK: - Lifecyle
    //--------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .None;

        view.backgroundColor = UIColor.blackColor()
        title = "TZStackView"

        tzStackView = TZStackView(arrangedSubviews: createViews())
        tzStackView.translatesAutoresizingMaskIntoConstraints = false
        tzStackView.axis = .Vertical
        tzStackView.distribution = .Fill
        tzStackView.alignment = .Fill
        tzStackView.spacing = 15
        view.addSubview(tzStackView)

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFontOfSize(15)
        instructionLabel.text = "Tap any of the boxes to set hidden=true"
        instructionLabel.textColor = UIColor.whiteColor()
        instructionLabel.numberOfLines = 0
        instructionLabel.setContentCompressionResistancePriority(900, forAxis: .Horizontal)
        instructionLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        view.addSubview(instructionLabel)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.addTarget(self, action: #selector(ViewController.reset), forControlEvents: .TouchUpInside)
        resetButton.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        resetButton.setContentHuggingPriority(1000, forAxis: .Horizontal)
        resetButton.setContentHuggingPriority(1000, forAxis: .Vertical)
        view.addSubview(resetButton)

        axisSegmentedControl = UISegmentedControl(items: ["Vertical", "Horizontal"])
        axisSegmentedControl.selectedSegmentIndex = 0
        axisSegmentedControl.addTarget(self, action: #selector(ViewController.axisChanged(_:)), forControlEvents: .ValueChanged)
        axisSegmentedControl.setContentCompressionResistancePriority(900, forAxis: .Horizontal)
        axisSegmentedControl.tintColor = UIColor.lightGrayColor()

        alignmentSegmentedControl = UISegmentedControl(items: ["Fill", "Center", "Leading", "Top", "Trailing", "Bottom", "FirstBaseline"])
        alignmentSegmentedControl.selectedSegmentIndex = 0
        alignmentSegmentedControl.addTarget(self, action: #selector(ViewController.alignmentChanged(_:)), forControlEvents: .ValueChanged)
        alignmentSegmentedControl.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        alignmentSegmentedControl.tintColor = UIColor.lightGrayColor()

        distributionSegmentedControl = UISegmentedControl(items: ["Fill", "FillEqually", "FillProportionally", "EqualSpacing", "EqualCentering"])
        distributionSegmentedControl.selectedSegmentIndex = 0
        distributionSegmentedControl.addTarget(self, action: #selector(ViewController.distributionChanged(_:)), forControlEvents: .ValueChanged)
        distributionSegmentedControl.tintColor = UIColor.lightGrayColor()

        let controlsLayoutContainer = TZStackView(arrangedSubviews: [axisSegmentedControl, alignmentSegmentedControl, distributionSegmentedControl])
        controlsLayoutContainer.axis = .Vertical
        controlsLayoutContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsLayoutContainer.spacing = 5
        controlsLayoutContainer.setContentHuggingPriority(1000, forAxis: .Vertical)
        view.addSubview(controlsLayoutContainer)

        let views: [String:AnyObject] = [
                "instructionLabel": instructionLabel,
                "resetButton": resetButton,
                "tzStackView": tzStackView,
                "controlsLayoutContainer": controlsLayoutContainer
        ]

        let metrics: [String:AnyObject] = [
                "gap": 10,
                "topspacing": 25
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-gap-[instructionLabel]-[resetButton]-gap-|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controlsLayoutContainer]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topspacing-[instructionLabel]-gap-[controlsLayoutContainer]-gap-[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topspacing-[resetButton]-gap-[controlsLayoutContainer]",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
    }

    private func createViews() -> [UIView] {
        let redView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Red")
        let greenView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Green")
        let blueView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 60, height: 60), name: "Blue")
        let purpleView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Purple")
        let yellowView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Yellow")

        redView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.75)
        greenView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.75)
        blueView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.75)
        purpleView.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.75)
        yellowView.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.75)
        return [redView, greenView, blueView, purpleView, yellowView]
    }

    //MARK: - Button Actions
    //--------------------------------------------------------------------------
    func reset() {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
            for view in self.tzStackView.arrangedSubviews {
                view.hidden = false
            }
        }, completion: nil)

    }

    //MARK: - Segmented Control Actions
    //--------------------------------------------------------------------------
    func axisChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.axis = .Vertical
        default:
            tzStackView.axis = .Horizontal
        }
    }

    func alignmentChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.alignment = .Fill
        case 1:
            tzStackView.alignment = .Center
        case 2:
            tzStackView.alignment = .Leading
        case 3:
            tzStackView.alignment = .Top
        case 4:
            tzStackView.alignment = .Trailing
        case 5:
            tzStackView.alignment = .Bottom
        default:
            tzStackView.alignment = .FirstBaseline
        }
        tzStackView.setNeedsUpdateConstraints()
    }

    func distributionChanged(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.distribution = .Fill
        case 1:
            tzStackView.distribution = .FillEqually
        case 2:
            tzStackView.distribution = .FillProportionally
        case 3:
            tzStackView.distribution = .EqualSpacing
        default:
            tzStackView.distribution = .EqualCentering
        }
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}