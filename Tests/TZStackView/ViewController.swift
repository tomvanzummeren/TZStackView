//
//  ViewController.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 10/06/15.
//  Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

@available(iOS 9.0, *)
class ViewController: UIViewController {
    
    var stackView: UIStackView!

    var tzStackView: TZStackView!
    
    let resetButton = UIButton(type: .System)

    let debugButton = UIButton(type: .System)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure original UIStackView
        stackView = UIStackView(arrangedSubviews: createViews())
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .Horizontal
        stackView.distribution = .FillEqually
        stackView.alignment = .Center
        stackView.baselineRelativeArrangement = true
        stackView.spacing = 15
        stackView.layoutMarginsRelativeArrangement = true
        view.addSubview(stackView)
        
        // Configure backwards compatible TZStackView the same way as UIStackView above
        tzStackView = TZStackView(arrangedSubviews: createViews())
        tzStackView.translatesAutoresizingMaskIntoConstraints = false
        tzStackView.axis = .Horizontal
        tzStackView.distribution = .FillEqually
        tzStackView.alignment = .Center
        tzStackView.spacing = 15
        tzStackView.layoutMarginsRelativeArrangement = true
        view.addSubview(tzStackView)
        
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("reset", forState: .Normal)
        resetButton.addTarget(self, action: "reset", forControlEvents: .TouchUpInside)
        view.addSubview(resetButton)

        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.setTitle("debug", forState: .Normal)
        debugButton.addTarget(self, action: "debugPrint", forControlEvents: .TouchUpInside)
        view.addSubview(debugButton)

        let views:[String: AnyObject] = ["stackView": stackView, "tzStackView": tzStackView, "resetButton": resetButton, "debugButton": debugButton]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[debugButton]-[resetButton]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[resetButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[debugButton]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))

        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[stackView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tzStackView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tzStackView(==stackView)]-1-[stackView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    
    func reset() {
        UIView.animateWithDuration(0.5) {
            for view in self.stackView.arrangedSubviews {
                view.hidden = false
            }
            for view in self.tzStackView.arrangedSubviews {
                view.hidden = false
            }
        }
    }
    
    private func createViews() -> [UIView] {
        let redView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Red", baselinePercentage: 0, baselineHeightPercentage: 0.2)
        let greenView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Green", baselinePercentage: 0.4, baselineHeightPercentage: 0.3)
        let blueView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Blue", baselinePercentage: 0.2, baselineHeightPercentage: 0.4)
        let purpleView = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSize(width: 80, height: 80), name: "Purple", baselinePercentage: 0.6, baselineHeightPercentage: 0.1)

        redView.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.75)
        greenView.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.75)
        blueView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.75)
        purpleView.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.75)
        return [redView, greenView, blueView, purpleView]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        debugPrint()
    }
    
    func debugPrint() {
//        print("== UIStackView (\(stackView.constraints.count) constraints) ==")
//        for constraint in stackView.constraints {
//            print(constraint.readableString())
//        }
//        for subview in stackView.arrangedSubviews {
//            print("\(subview):")
//            for constraint in subview.constraints {
//                print("  \(constraint.readableString())")
//            }
//        }
//        print("")
//        print("== TZStackView (\(tzStackView.constraints.count) constraints) ==")
//        for constraint in tzStackView.constraints {
//            print(constraint.readableString())
//        }
//        for subview in tzStackView.arrangedSubviews {
//            print("\(subview):")
//            for constraint in subview.constraints {
//                print("  \(constraint.readableString())")
//            }
//        }
    }
}
