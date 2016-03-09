//
//  TZAnimationDelegate.swift
//  TZStackView
//
//  Created by CosynPa on 3/5/16.
//  Copyright © 2016 Tom van Zummeren. All rights reserved.
//

import Foundation
import QuartzCore

class TZFuncAnimationDelegate {
    private var completionFunc: ((CAAnimation, Bool) -> ())?
    
    init(completion: (CAAnimation, Bool) -> ()) {
        completionFunc = completion
    }
    
    @objc func animationDidStart(anim: CAAnimation) {

    }
    
    @objc func animationDidStop(anim: CAAnimation, finished: Bool) {
        completionFunc?(anim, finished)
    }
    
    func cancel(anim: CAAnimation) {
        completionFunc?(anim, false)
        completionFunc = nil
    }
}