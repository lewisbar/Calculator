//
//  AdaptiveUIHelper.swift
//  Calculator
//
//  Created by Lennart Wisbar on 20.05.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

extension CalculatorVC {
    enum Situation {
        case start
        
        case digit
        case floatingPoint
        
        case constant
        case unary
        case binary
        case equals
        
        case deletedLastDigit
    }
    
    func adaptView(to situation: Situation) {
        currentSituation = situation
        if !uiIsAdaptive {
            adaptViewToNonAdaptive()
            return
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.digitButtons.forEach { $0.isHidden = !self.shouldShowDigitButtons(in: situation) }
            self.binaryOperationButtons.forEach { $0.isHidden = !self.shouldShowBinaryOperationButtons(in: situation) }
            self.unaryOperationButtons.forEach { $0.isHidden = !self.shouldShowUnaryOperationButtons(in: situation) }
            self.constantButtons.forEach { $0.isHidden = !self.shouldShowConstantButtons(in: situation) }
            self.floatingPointButton.isHidden = !self.shouldShowFloatingPointButton(in: situation)
            self.clearButton.isHidden = !self.shouldShowClearButton(in: situation)
            
            // TODO: This loop is a workaround for a bug I don't understand yet. The equals button seems equal (pun intended) to all the other buttons, yet it's the only one that needs three calls to finally show up again. I tried changing the order of the buttons, deleting and recreating the button and changing its colors to be exactly like the others. It all made no difference.
            while self.equalsButton.isHidden == self.shouldShowEqualsButton(in: situation) {
                self.equalsButton.isHidden = !self.shouldShowEqualsButton(in: situation)
            }
            
            
            if self.uiIsAdaptive && (self.displayValue?.isLess(than: 0)) ?? false {
                self.squareRootButton.isHidden = true
            }
            
            self.showOnlyNonEmptyStackViews()
        }
    }
    
    // MARK: - Private Implementation
    private var animationDuration: Double { return 0.25 }
    
    private func adaptViewToNonAdaptive() {
        UIView.animate(withDuration: animationDuration) {
            self.digitButtons.forEach { $0.isHidden = false }
            self.binaryOperationButtons.forEach { $0.isHidden = false }
            self.unaryOperationButtons.forEach { $0.isHidden = false }
            self.constantButtons.forEach { $0.isHidden = false }
            self.floatingPointButton.isHidden = false
            self.clearButton.isHidden = false
            
            // TODO: This loop is a workaround for a bug I don't understand yet. The equals button seems equal (pun intended) to all the other buttons, yet it's the only one that needs three calls to finally show up again. I tried changing the order of the buttons, deleting and recreating the button and changing its colors to be exactly like the others. It all made no difference.
            while self.equalsButton.isHidden == true {
                self.equalsButton.isHidden = false
            }
            
            self.showOnlyNonEmptyStackViews()
        }
    }
    
    // Helper method for adaptView(to:)
    private func showOnlyNonEmptyStackViews() {
        for stackView in buttonRows {
            stackView.isHidden = stackViewWillBeVisuallyEmpty(stackView)
        }
    }
    
    // Helper method for showOnlyNonEmptyStackViews()
    private func stackViewWillBeVisuallyEmpty(_ stackView: UIStackView) -> Bool {
        for view in stackView.subviews {
            if !view.isHidden { return false }
        }
        return true
    }
    
    // MARK: - Button Visibility Settings
    private func shouldShowDigitButtons(in situation: Situation) -> Bool {
        switch situation {
        case .start: return true
        case .digit: return true
        case .floatingPoint: return true
        case .constant: return false
        case .unary: return brain.evaluate().isPending ? false : true
        case .binary: return true
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowBinaryOperationButtons(in situation: Situation) -> Bool {
        switch situation {
        case .start: return false
        case .digit: return true
        case .floatingPoint: return true
        case .constant: return true
        case .unary: return true
        case .binary: return false
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowUnaryOperationButtons(in situation: Situation) -> Bool {
        switch situation {
        case .start: return false
        case .digit: return true
        case .floatingPoint: return true
        case .constant: return true
        case .unary: return true
        case .binary: return false
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowConstantButtons(in situation: Situation) -> Bool {
        switch situation {
        case .start: return true
        case .digit: return false
        case .floatingPoint: return false
        case .constant: return false
        case .unary: return brain.evaluate().isPending ? false : true
        case .binary: return true
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowFloatingPointButton(in situation: Situation) -> Bool {
        switch situation {
        case .start: return true
        case .digit: return (display.text?.contains(localDecimalSeparator))! ? false : true
        case .floatingPoint: return true
        case .constant: return false
        case .unary: return brain.evaluate().isPending ? false : true
        case .binary: return true
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowClearButton(in situation: Situation) -> Bool {
        switch situation {
        case .start: return false
        case .digit: return true
        case .floatingPoint: return true
        case .constant: return true
        case .unary: return true
        case .binary: return true
        case .equals: return true
        case .deletedLastDigit: return true
        }
    }
    
    private func shouldShowEqualsButton(in situation: Situation) -> Bool {
        switch situation {
        case .start: return false
        case .digit: return brain.evaluate().isPending ? true : false
        case .floatingPoint: return brain.evaluate().isPending ? true : false
        case .constant: return brain.evaluate().isPending ? true : false
        case .unary: return brain.evaluate().isPending ? true : false
        case .binary: return false
        case .equals: return false
        case .deletedLastDigit: return brain.evaluate().isPending ? true : false
        }
    }
}
