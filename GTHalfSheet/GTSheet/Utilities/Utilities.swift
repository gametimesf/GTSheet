//
//  Util.swift
//  GTHalfSheet
//
//  Created by Matt Banach on 9/22/17.
//  Copyright © 2017 Gametime. All rights reserved.
//

import Foundation

extension UIView {

    @discardableResult func bindToSuperView(edgeInsets: UIEdgeInsets) -> [NSLayoutConstraint] {

        guard let superview = self.superview else {
            return []
        }

        translatesAutoresizingMaskIntoConstraints = false

        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-left-[subview]-right-|",
            options: [],
            metrics: [
                "left": edgeInsets.left,
                "right": edgeInsets.right
            ],
            views: [
                "subview": self
            ]
        )

        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-top-[subview]-bottom-|",
            options: [],
            metrics: [
                "top": edgeInsets.top,
                "bottom": edgeInsets.bottom
            ],
            views: [
                "subview": self
            ]
        )

        superview.addConstraints(horizontalConstraints + verticalConstraints)

        return horizontalConstraints + verticalConstraints
    }

}

extension CGAffineTransform {

    var as3D: CATransform3D {
        return CATransform3DMakeAffineTransform(self)
    }
}

extension CATransform3D {

    static var identity: CATransform3D {
        return CATransform3DIdentity
    }
}

struct HapticHelper {

    static func warmUp() {
        UIImpactFeedbackGenerator().prepare()
    }

    static func impact() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}
