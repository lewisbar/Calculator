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
    var cornerRadius: CGFloat = 5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }

}
