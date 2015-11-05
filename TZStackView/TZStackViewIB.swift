//
//  TZStackViewIB.swift
//  TZStackView
//
//  Created by Paul Jones on 9/30/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//


extension TZStackView {
    @IBInspectable var ibDistribution: Int {
        set(newValue) {
            self.distribution = TZStackViewDistribution(rawValue: newValue)!
        }
        get {
            return self.distribution.rawValue
        }
    }
    
    @IBInspectable var ibAxis: Int {
        set(newValue) {
            self.axis = UILayoutConstraintAxis(rawValue: newValue)!
        }
        get {
            return self.axis.rawValue
        }
    }
    
    @IBInspectable var ibAlignment: Int {
        set(newValue) {
            self.alignment = TZStackViewAlignment(rawValue: newValue)!
        }
        get {
            return self.alignment.rawValue
        }
    }
    
    @IBInspectable var ibSpacing: CGFloat {
        set(newValue) {
            self.spacing = newValue
        }
        get {
            return self.spacing
        }
    }
    
    @IBInspectable var numberOfArrangedSubviews: Int {
        set(newValue) {
            
            #if !TARGET_INTERFACE_BUILDER
                for view in self.subviews {
                    view.removeFromSuperview()
                    self.addSubview(view)
                }
                self.arrangedSubviews = self.subviews
                #else
                var views = Array<UIView>()
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                
                for _ in 0...newValue {
                    let view = ExplicitIntrinsicContentSizeView(intrinsicContentSize: CGSizeMake(100, 100), name: "Hello")
                    view.backgroundColor = UIColor.blueColor()
                    views.append(view)
                }
                
                for arrangedSubview in views {
                    arrangedSubview.translatesAutoresizingMaskIntoConstraints = false
                    self.addSubview(arrangedSubview)
                }
                
                self.arrangedSubviews = views
            #endif
            
        }
        get {
            return self.arrangedSubviews.count
        }
    }
}