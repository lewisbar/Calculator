//
//  AdaptiveUIHelper.swift
//  Calculator
//
//  Created by Lennart Wisbar on 20.05.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

struct AdaptiveUIState {
    static var uiIsAdaptive = true
    static var currentSituation = Situation.start
}

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

extension CalculatorVC {
    // MARK: - Detect Shake Gesture to Toggle Adaptive Interface
    override var canBecomeFirstResponder: Bool { return true }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            AdaptiveUIState.uiIsAdaptive = !AdaptiveUIState.uiIsAdaptive
            adaptView(to: AdaptiveUIState.currentSituation)
        }
    }
    
    // MARK: - Main Adaption Function
    func adaptView(to situation: Situation) {
        AdaptiveUIState.currentSituation = situation
        if !AdaptiveUIState.uiIsAdaptive {
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
            
            
            if self.displayValue?.isLess(than: 0) ?? false {
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
}
