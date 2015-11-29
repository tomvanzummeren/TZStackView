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

        let toIBButton = UIButton(type: .System)
        toIBButton.translatesAutoresizingMaskIntoConstraints = false
        toIBButton.setTitle("Storyboard Views", forState: .Normal)
        toIBButton.addTarget(self, action: "toIB", forControlEvents: .TouchUpInside)
        toIBButton.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        toIBButton.setContentHuggingPriority(1000, forAxis: .Vertical)
        view.addSubview(toIBButton)

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFontOfSize(15)
        instructionLabel.text = "Tap any of the boxes to set hidden=true"
        instructionLabel.textColor = UIColor.whiteColor()
        instructionLabel.numberOfLines = 0
        instructionLabel.setContentCompressionResistancePriority(900, forAxis: .Horizontal)
        instructionLabel.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        instructionLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        view.addSubview(instructionLabel)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", forState: .Normal)
        resetButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
        resetButton.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        resetButton.setContentHuggingPriority(1000, forAxis: .Horizontal)
        view.addSubview(resetButton)

        axisSegmentedControl = UISegmentedControl(items: ["Vertical", "Horizontal"])
        axisSegmentedControl.selectedSegmentIndex = 0
        axisSegmentedControl.addTarget(self, action: "axisChanged:", forControlEvents: .ValueChanged)
        axisSegmentedControl.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        axisSegmentedControl.setContentHuggingPriority(1000, forAxis: .Vertical)
        axisSegmentedControl.tintColor = UIColor.lightGrayColor()

        alignmentSegmentedControl = UISegmentedControl(items: ["Fill", "Center", "Leading", "Top", "Trailing", "Bottom", "FirstBaseline"])
        alignmentSegmentedControl.selectedSegmentIndex = 0
        alignmentSegmentedControl.addTarget(self, action: "alignmentChanged:", forControlEvents: .ValueChanged)
        alignmentSegmentedControl.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        alignmentSegmentedControl.setContentHuggingPriority(1000, forAxis: .Vertical)
        alignmentSegmentedControl.tintColor = UIColor.lightGrayColor()

        distributionSegmentedControl = UISegmentedControl(items: ["Fill", "FillEqually", "FillProportionally", "EqualSpacing", "EqualCentering"])
        distributionSegmentedControl.selectedSegmentIndex = 0
        distributionSegmentedControl.addTarget(self, action: "distributionChanged:", forControlEvents: .ValueChanged)
        distributionSegmentedControl.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        distributionSegmentedControl.setContentHuggingPriority(1000, forAxis: .Vertical)
        distributionSegmentedControl.tintColor = UIColor.lightGrayColor()

        let controlsLayoutContainer = TZStackView(arrangedSubviews: [axisSegmentedControl, alignmentSegmentedControl, distributionSegmentedControl])
        controlsLayoutContainer.axis = .Vertical
        controlsLayoutContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsLayoutContainer.spacing = 5
        view.addSubview(controlsLayoutContainer)

        let views: [String:AnyObject] = [
                "toIBButton": toIBButton,
                "instructionLabel": instructionLabel,
                "resetButton": resetButton,
                "tzStackView": tzStackView,
                "controlsLayoutContainer": controlsLayoutContainer
        ]

        let metrics: [String:AnyObject] = [
                "gap": 10,
                "topspacing": 25
        ]

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[toIBButton]-gap-|",
            options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-gap-[instructionLabel]-[resetButton]-gap-|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[controlsLayoutContainer]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-topspacing-[toIBButton]-gap-[instructionLabel]-gap-[controlsLayoutContainer]-gap-[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: instructionLabel, attribute: .CenterY, relatedBy: .Equal, toItem: resetButton, attribute: .CenterY, multiplier: 1, constant: 0))
    }

    private func createViews() -> [UIView] {
        let redView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Red")
        let greenView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Green")
        let blueView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 60, height: 60), name: "Blue")
        let purpleView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Purple")
        let yellowView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Yellow")
        
        let views = [redView, greenView, blueView, purpleView, yellowView]
        
        for (i, view) in views.enumerate() {
            let j = UILayoutPriority(i)
            view.setContentCompressionResistancePriority(751 + j, forAxis: .Horizontal)
            view.setContentCompressionResistancePriority(751 + j, forAxis: .Vertical)
            view.setContentHuggingPriority(251 + j, forAxis: .Horizontal)
            view.setContentHuggingPriority(251 + j, forAxis: .Vertical)
        }

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
    
    func toIB() {
        
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()!
        viewController.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: "backFromIB")
        
        let navController = UINavigationController(rootViewController: viewController)
        
        presentViewController(navController, animated: true, completion: nil)
        
    }
    
    func backFromIB() {
        dismissViewControllerAnimated(true, completion:nil)
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