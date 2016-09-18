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

    let resetButton = UIButton(type: .system)
    let instructionLabel = UILabel()

    var axisSegmentedControl: UISegmentedControl!
    var alignmentSegmentedControl: UISegmentedControl!
    var distributionSegmentedControl: UISegmentedControl!

    //MARK: - Lifecyle
    //--------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = UIRectEdge();

        view.backgroundColor = UIColor.black
        title = "TZStackView"

        tzStackView = TZStackView(arrangedSubviews: createViews())
        tzStackView.translatesAutoresizingMaskIntoConstraints = false
        tzStackView.axis = .vertical
        tzStackView.distribution = .fill
        tzStackView.alignment = .fill
        tzStackView.spacing = 15
        view.addSubview(tzStackView)

        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.font = UIFont.systemFont(ofSize: 15)
        instructionLabel.text = "Tap any of the boxes to set hidden=true"
        instructionLabel.textColor = UIColor.white
        instructionLabel.numberOfLines = 0
        instructionLabel.setContentCompressionResistancePriority(900, for: .horizontal)
        instructionLabel.setContentHuggingPriority(1000, for: .vertical)
        view.addSubview(instructionLabel)

        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("Reset", for: UIControlState())
        resetButton.addTarget(self, action: #selector(ViewController.reset), for: .touchUpInside)
        resetButton.setContentCompressionResistancePriority(1000, for: .horizontal)
        resetButton.setContentHuggingPriority(1000, for: .horizontal)
        resetButton.setContentHuggingPriority(1000, for: .vertical)
        view.addSubview(resetButton)

        axisSegmentedControl = UISegmentedControl(items: ["Vertical", "Horizontal"])
        axisSegmentedControl.selectedSegmentIndex = 0
        axisSegmentedControl.addTarget(self, action: #selector(ViewController.axisChanged(_:)), for: .valueChanged)
        axisSegmentedControl.setContentCompressionResistancePriority(900, for: .horizontal)
        axisSegmentedControl.tintColor = UIColor.lightGray

        alignmentSegmentedControl = UISegmentedControl(items: ["Fill", "Center", "Leading", "Top", "Trailing", "Bottom", "FirstBaseline"])
        alignmentSegmentedControl.selectedSegmentIndex = 0
        alignmentSegmentedControl.addTarget(self, action: #selector(ViewController.alignmentChanged(_:)), for: .valueChanged)
        alignmentSegmentedControl.setContentCompressionResistancePriority(1000, for: .horizontal)
        alignmentSegmentedControl.tintColor = UIColor.lightGray

        distributionSegmentedControl = UISegmentedControl(items: ["Fill", "FillEqually", "FillProportionally", "EqualSpacing", "EqualCentering"])
        distributionSegmentedControl.selectedSegmentIndex = 0
        distributionSegmentedControl.addTarget(self, action: #selector(ViewController.distributionChanged(_:)), for: .valueChanged)
        distributionSegmentedControl.tintColor = UIColor.lightGray

        let controlsLayoutContainer = TZStackView(arrangedSubviews: [axisSegmentedControl, alignmentSegmentedControl, distributionSegmentedControl])
        controlsLayoutContainer.axis = .vertical
        controlsLayoutContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsLayoutContainer.spacing = 5
        controlsLayoutContainer.setContentHuggingPriority(1000, for: .vertical)
        view.addSubview(controlsLayoutContainer)

        let views: [String:AnyObject] = [
                "instructionLabel": instructionLabel,
                "resetButton": resetButton,
                "tzStackView": tzStackView,
                "controlsLayoutContainer": controlsLayoutContainer
        ]

        let metrics: [String:AnyObject] = [
                "gap": 10 as AnyObject,
                "topspacing": 25 as AnyObject
        ]

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-gap-[instructionLabel]-[resetButton]-gap-|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[controlsLayoutContainer]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))

        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topspacing-[instructionLabel]-gap-[controlsLayoutContainer]-gap-[tzStackView]|",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-topspacing-[resetButton]-gap-[controlsLayoutContainer]",
                options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
    }

    fileprivate func createViews() -> [UIView] {
        let redView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Red")
        let greenView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Green")
        let blueView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 60, height: 60), name: "Blue")
        let purpleView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Purple")
        let yellowView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 100, height: 100), name: "Yellow")

        redView.backgroundColor = UIColor.red.withAlphaComponent(0.75)
        greenView.backgroundColor = UIColor.green.withAlphaComponent(0.75)
        blueView.backgroundColor = UIColor.blue.withAlphaComponent(0.75)
        purpleView.backgroundColor = UIColor.purple.withAlphaComponent(0.75)
        yellowView.backgroundColor = UIColor.yellow.withAlphaComponent(0.75)
        return [redView, greenView, blueView, purpleView, yellowView]
    }

    //MARK: - Button Actions
    //--------------------------------------------------------------------------
    func reset() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            for view in self.tzStackView.arrangedSubviews {
                view.isHidden = false
            }
        }, completion: nil)

    }

    //MARK: - Segmented Control Actions
    //--------------------------------------------------------------------------
    func axisChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.axis = .vertical
        default:
            tzStackView.axis = .horizontal
        }
    }

    func alignmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.alignment = .fill
        case 1:
            tzStackView.alignment = .center
        case 2:
            tzStackView.alignment = .leading
        case 3:
            tzStackView.alignment = .top
        case 4:
            tzStackView.alignment = .trailing
        case 5:
            tzStackView.alignment = .bottom
        default:
            tzStackView.alignment = .firstBaseline
        }
        tzStackView.setNeedsUpdateConstraints()
    }

    func distributionChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            tzStackView.distribution = .fill
        case 1:
            tzStackView.distribution = .fillEqually
        case 2:
            tzStackView.distribution = .fillProportionally
        case 3:
            tzStackView.distribution = .equalSpacing
        default:
            tzStackView.distribution = .equalCentering
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
