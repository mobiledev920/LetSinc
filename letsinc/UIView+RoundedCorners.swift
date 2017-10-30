//
//  UIView+RoundedCorners.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 20/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
