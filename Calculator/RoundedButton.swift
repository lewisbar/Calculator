//
//  RoundedButton.swift
//  Calculator
//
//  Created by Lennart Wisbar on 11.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 5
        clipsToBounds = true
    }

}
