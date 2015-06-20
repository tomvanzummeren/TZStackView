//
// Created by Tom van Zummeren on 10/06/15.
// Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

class ExplicitIntrinsicContentSizeView: UIView {

    let name: String
    let contentSize: CGSize
    
    let baselineView: UIView = UIView()
    
    var baselinePercentage: CGFloat
    var baselineHeightPercentage: CGFloat

    init(intrinsicContentSize: CGSize, name: String, baselinePercentage: CGFloat, baselineHeightPercentage: CGFloat) {
        self.baselinePercentage = baselinePercentage
        self.baselineHeightPercentage = baselineHeightPercentage
        self.name = name
        self.contentSize = intrinsicContentSize
        super.init(frame: CGRectZero)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        addGestureRecognizer(gestureRecognizer)
        userInteractionEnabled = true
        
        baselineView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        addSubview(baselineView)
    }
    
    func tap() {
        UIView.animateWithDuration(0.5, delay:0, options: .AllowUserInteraction, animations: {
            self.hidden = true
        }, completion: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let baselineY = bounds.size.height * baselinePercentage
        let baselineHeight = bounds.size.height * baselineHeightPercentage
        baselineView.frame = CGRect(x: bounds.size.width * (1 / 10), y: baselineY, width: bounds.size.width * (8 / 10), height: baselineHeight)
    }
    
    override func viewForBaselineLayout() -> UIView {
        return baselineView
    }

    override var viewForLastBaselineLayout: UIView {
        return baselineView
    }
    
    override func intrinsicContentSize() -> CGSize {
        return contentSize
    }
    
    override var description: String  {
        return name
    }

}
