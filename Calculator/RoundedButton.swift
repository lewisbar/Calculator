//
//  RoundedButton.swift
//  Calculator
//
//  Created by Lennart Wisbar on 11.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton, Hidable {
//    @IBInspectable
//    var cornerRadius: CGFloat = 5 {
//        didSet {
//            roundCorners()
//        }
//    }
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        roundCorners()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        roundCorners()
//    }
//    
//    private func roundCorners() {
//        layer.cornerRadius = cornerRadius
//        clipsToBounds = true
//    }
    
    var shouldShow: Dictionary<Situation, Bool> = [
        .start: true,
        .digit: true,
        .floatingPoint: true,
        .constant: true,
        .unary: true,
        .binary: true,
        .equals: true,
        .deletedLastDigit: true
    ]

//    var shouldShowWhenStart = true
//    var shouldShowWhenDigit = true
//    var shouldShowWhenFloatingPoint = true
//    var shouldShowWhenConstant = true
//    var shouldShowWhenUnary = true
//    var shouldShowWhenBinary = true
//    var shouldShowWhenEquals = true
//    var shouldShowWhenDeletedLastDigit = true
}
