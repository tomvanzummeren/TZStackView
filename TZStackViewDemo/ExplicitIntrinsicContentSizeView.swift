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
        super.init(frame: CGRect.zero)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ExplicitIntrinsicContentSizeView.tap))
        addGestureRecognizer(gestureRecognizer)
        isUserInteractionEnabled = true
    }

    @objc func tap() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            self.isHidden = true
        }, completion: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize : CGSize {
        return contentSize
    }

    override var description: String {
        return name
    }

}
