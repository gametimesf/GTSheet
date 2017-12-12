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

    func add(gestureRecognizer: UIGestureRecognizer?) {
        guard let gestureRecognizer = gestureRecognizer else { return }
        addGestureRecognizer(gestureRecognizer)
    }

    func round(corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }

    func snapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
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

extension UIScrollView {
    var isScrolling: Bool {
        return isDragging || isDecelerating
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


extension UIEdgeInsets {

    init(withTop top: CGFloat = 0.0) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }

    init(withBottom bottom: CGFloat = 0.0) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }
}
