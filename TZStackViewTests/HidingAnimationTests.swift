//
//  HidingAnimationTests.swift
//  TZStackView
//
//  Created by CosynPa on 3/6/16.
//  Copyright © 2016 Tom van Zummeren. All rights reserved.
//

import Foundation
import UIKit
import XCTest
import TZStackView

class HidingAnimationTests: TZStackViewTestCase {
    var uiTestView: UIView!
    var tzTestView: UIView!
    
    override func createTestViews() -> [UIView] {
        var views = [UIView]()
        for i in 0 ..< 5 {
            views.append(TestView(index: i, size: CGSize(width: 100 * (i + 1), height: 100 * (i + 1))))
        }
        return views
    }
    
    override func setUp() {
        super.setUp()
        uiTestView = uiStackView.arrangedSubviews.last!
        tzTestView = tzStackView.arrangedSubviews.last!
    }
    
    // If you are not animating the hidden property, the hidden property should be set immediately
    func testNonAnimatingHidden() {
        let expectation = expectationWithDescription("delay")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.uiTestView.hidden = true
            self.tzTestView.hidden = true
            
            XCTAssert(self.uiTestView.hidden)
            XCTAssert(self.tzTestView.hidden)
            XCTAssert(self.uiTestView.layer.hidden)
            XCTAssert(self.tzTestView.layer.hidden)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    // If you are not animating the hidden property, the hidden property should be set immediately
    func testNonAnimatingHiddenWithOther() {
        let expectation = expectationWithDescription("delay")
        
        uiTestView.backgroundColor = UIColor.clearColor()
        tzTestView.backgroundColor = UIColor.clearColor()
        UIView.animateWithDuration(2) {
            self.uiTestView.backgroundColor = UIColor.greenColor()
            self.tzTestView.backgroundColor = UIColor.greenColor()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.uiTestView.hidden = true
            self.tzTestView.hidden = true
            
            XCTAssert(self.uiTestView.hidden)
            XCTAssert(self.tzTestView.hidden)
            XCTAssert(self.uiTestView.layer.hidden)
            XCTAssert(self.tzTestView.layer.hidden)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    func animationHiddenWithDelay(delay: NSTimeInterval) {
        let expectation = expectationWithDescription("delay")
        
        let duration = 1.0
        
        UIView.animateWithDuration(duration, delay: delay, options: [],
            animations: { () -> Void in
                self.uiTestView.hidden = true
                self.tzTestView.hidden = true
                
                // Note uiTestView.hidden == true, tzTestView.hidden == false
                
                // The presentation should not be hidden.
                XCTAssert(!self.uiTestView.layer.hidden)
                XCTAssert(!self.tzTestView.layer.hidden)
                
            }, completion: { _ in
                XCTAssert(self.uiTestView.hidden)
                XCTAssert(self.tzTestView.hidden)
                XCTAssert(self.uiTestView.layer.hidden)
                XCTAssert(self.tzTestView.layer.hidden)
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((duration + delay + 0.2) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            XCTAssert(self.uiTestView.hidden)
            XCTAssert(self.tzTestView.hidden)
            XCTAssert(self.uiTestView.layer.hidden)
            XCTAssert(self.tzTestView.layer.hidden)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((duration + delay + 0.4) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    func testAnimatingHidden() {
        animationHiddenWithDelay(0)
    }
    
    func testAnimatingHiddenWithDelay() {
        animationHiddenWithDelay(1)
    }
    
    func testAnimatingHiddenWithOther() {
        let expectation = expectationWithDescription("delay")
        
        UIView.animateWithDuration(1) {
            self.uiTestView.hidden = true
            self.tzTestView.hidden = true
        }
        
        uiTestView.backgroundColor = UIColor.clearColor()
        tzTestView.backgroundColor = UIColor.clearColor()
        UIView.animateWithDuration(2) {
            self.uiTestView.backgroundColor = UIColor.greenColor()
            self.tzTestView.backgroundColor = UIColor.greenColor()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            // The view should be hidden after the hiding animation completes even if there are still other animations
            XCTAssert(self.uiTestView.hidden)
            XCTAssert(self.tzTestView.hidden)
            XCTAssert(self.uiTestView.layer.hidden)
            XCTAssert(self.tzTestView.layer.hidden)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    // The completion callback of an animation should be called
    func testHidingAnimationCallback() {
        let expectation = expectationWithDescription("delay")
        
        var uiCompletionCalled = false
        var tzCompletionCalled = false
        
        UIView.animateWithDuration(1,
            animations: {
                self.uiTestView.hidden = true
            }, completion: { _ in
                uiCompletionCalled = true
        })
        
        UIView.animateWithDuration(1,
            animations: {
                self.tzTestView.hidden = true
            }, completion: { _ in
                tzCompletionCalled = true
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            XCTAssert(uiCompletionCalled)
            XCTAssert(tzCompletionCalled)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.4 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    // The completion callback of an animation should be called when the animation is canceled
    func testHidingAnimationCallbackCancel() {
        let expectation = expectationWithDescription("delay")
        
        var uiCompletionCalled = false
        var tzCompletionCalled = false
        
        UIView.animateWithDuration(1,
            animations: {
                self.uiTestView.hidden = true
            }, completion: { finished in
                uiCompletionCalled = true
                XCTAssert(!finished)
        })
        
        UIView.animateWithDuration(1,
            animations: {
                self.tzTestView.hidden = true
            }, completion: { finished in
                tzCompletionCalled = true
                XCTAssert(!finished)
        })
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            // This will cancel the animation
            self.uiStackView.removeFromSuperview()
            self.tzStackView.removeFromSuperview()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            XCTAssert(uiCompletionCalled)
            XCTAssert(tzCompletionCalled)
            XCTAssert(self.uiTestView.hidden)
            XCTAssert(self.tzTestView.hidden)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.4 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    // When set the hidden property in the middle of an animation, the hidden property should be updated eventually
    func hidingAnimationSetAgainFirstHidden(firstHidden: Bool, withAnimation: Bool) {
        let expectation = expectationWithDescription("delay")
        
        uiTestView.hidden = firstHidden
        tzTestView.hidden = firstHidden
        
        UIView.animateWithDuration(2) {
            self.uiTestView.hidden = !firstHidden
            self.tzTestView.hidden = !firstHidden
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            if !withAnimation {
                self.uiTestView.hidden = firstHidden
                self.tzTestView.hidden = firstHidden
            } else {
                UIView.animateWithDuration(2) {
                    self.uiTestView.hidden = firstHidden
                    self.tzTestView.hidden = firstHidden
                    
                    // Animating, the presentation is not hidden
                    XCTAssert(!self.uiTestView.layer.hidden)
                    XCTAssert(!self.tzTestView.layer.hidden)
                }
            }
            
            // Note, here we don't expect the hidden property to be the right value even when without animation,
        }
        
        let endTime = !withAnimation ? 2.2 : 3.2
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(endTime * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            XCTAssert(self.uiTestView.hidden == firstHidden)
            XCTAssert(self.tzTestView.hidden == firstHidden)
        }
                
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64((endTime + 0.2) * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(100, handler: nil)
    }
    
    func testHidingAnimationSetAgainFirstNotHidden() {
        hidingAnimationSetAgainFirstHidden(false, withAnimation: false)
    }
    
    func testHidingAnimationSetAgainFirstHidden() {
        hidingAnimationSetAgainFirstHidden(true, withAnimation: false)
    }
    
    func testHidingAnimationSetAgainFirstNotHiddenWithAnimation() {
        hidingAnimationSetAgainFirstHidden(false, withAnimation: true)
    }
    
    func testHidingAnimationSetAgainFirstHiddenWithAnimation() {
        hidingAnimationSetAgainFirstHidden(true, withAnimation: true)
    }
}