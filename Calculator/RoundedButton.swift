//
//  RoundedButton.swift
//  Calculator
//
//  Created by Lennart Wisbar on 11.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable
    var cornerRadius: CGFloat = 5 {
        didSet {
            roundCorners()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        roundCorners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        roundCorners()
    }
    
    private func roundCorners() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
}
