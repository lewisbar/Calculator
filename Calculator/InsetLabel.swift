//
//  CalculatorDisplay.swift
//  Calculator
//
//  Created by Lennart Wisbar on 10.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class InsetLabel: UILabel {

    // Adding a padding on the left an right of the text.
    // This solution is almost entirely andrewz' answer at
    // https://stackoverflow.com/questions/27459746/adding-space-padding-to-a-uilabel/42046038#42046038
    // I only changed the first line which was
    // "open var insets : UIEdgeInsets = UIEdgeInsets() {"
    // to default inset values
    // and removed unnecessary open keywords.
    
    var insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) {
        didSet {
            super.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += insets.left + insets.right
        size.height += insets.top + insets.bottom
        return size
    }
    
    override func drawText(in rect: CGRect) {
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }

}
