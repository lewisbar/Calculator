//
//  UIView+Extension.swift
//  Calculator
//
//  Created by Lennart Wisbar on 20.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

extension UIView {
    
    func hide() {
        UIView.animate(withDuration: 0.5) {
            self.isHidden = true
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.5) {
            self.isHidden = false
        }
    }
}
