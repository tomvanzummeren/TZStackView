//
// Created by Tom van Zummeren on 10/06/15.
// Copyright (c) 2015 Tom van Zummeren. All rights reserved.
//

import UIKit

class ExplicitIntrinsicContentSizeView: UIView {

    let name: String
    let contentSize: CGSize

    init(intrinsicContentSize: CGSize, name: String) {
        self.name = name
        self.contentSize = intrinsicContentSize
        super.init(frame: CGRectZero)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExplicitIntrinsicContentSizeView.tap))
        addGestureRecognizer(gestureRecognizer)
        userInteractionEnabled = true
    }

    func tap() {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .AllowUserInteraction, animations: {
            self.hidden = true
        }, completion: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func intrinsicContentSize() -> CGSize {
        return contentSize
    }

    override var description: String {
        return name
    }

}
