//
//  CalculatorDisplay.swift
//  Calculator
//
//  Created by Lennart Wisbar on 10.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

@IBDesignable
class InsetLabel: UILabel {
    
    // MARK: - Insets
    
    // Adding a padding on the left an right of the text.
    // This solution is mostly andrewz' answer at
    // https://stackoverflow.com/questions/27459746/adding-space-padding-to-a-uilabel/42046038#42046038
    //    var insets : UIEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) {
    //        didSet {
    //            super.invalidateIntrinsicContentSize()
    //        }
    //    }
    //    override var intrinsicContentSize: CGSize {
    //        var size = super.intrinsicContentSize
    //        size.width += insets.left + insets.right
    //        size.height += insets.top + insets.bottom
    //        return size
    //    }
    
    @IBInspectable
    var sideInsets: CGFloat = 10 {
        didSet {
            super.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += sideInsets * 2
        return size
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: 0, left: sideInsets, bottom: 0, right: sideInsets)
        return super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    // MARK: - Dynamic font size
    @IBInspectable
    var fontSizeShouldBeLabelHeightMinus: CGFloat = 8 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        font = fontToFitHeight()
    }
    
    private func fontToFitHeight() -> UIFont {
        let font = self.font.withSize(bounds.height-fontSizeShouldBeLabelHeightMinus)
        return font
    }
    
    // MARK: - Rounded corners
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
