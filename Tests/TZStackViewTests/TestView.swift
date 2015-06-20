//
//  TestView.swift
//  TZStackView
//
//  Created by Tom van Zummeren on 11/06/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

class TestView: UIView {
    
    let index: Int
    let size: CGSize

    init(index: Int, size: CGSize) {
        self.index = index
        self.size = size
        super.init(frame: CGRectZero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var description: String  {
        return "TestView\(index)"
    }
    
    override func intrinsicContentSize() -> CGSize {
        return size
    }
}

 func ==(lhs: NSObject, rhs: NSObject) -> Bool {
    if let lhs = lhs as? TestView, rhs = rhs as? TestView {
        return lhs.index == rhs.index
    }
    return lhs === rhs
}