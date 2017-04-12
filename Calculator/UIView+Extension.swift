//
//  UIView+Extension.swift
//  Calculator
//
//  Created by Lennart Wisbar on 11.04.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
