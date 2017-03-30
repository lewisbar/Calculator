//
//  ViewController.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {
    
    // MARK: Vars
    private var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping = false
    private let localDecimalSeparator = (NSLocale.current.decimalSeparator as String?) ?? "."
    // private var hidableViews = [UIView]()
    private var displayValue: Double? {
        get {
            let formatter = NumberFormatter()
            let number = formatter.number(from: display.text!)
            return number?.doubleValue
        }
        set {
            self.display.text = newValue?.decimalFormat
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var display: InsetLabel!
    @IBOutlet weak var descriptionLabel: InsetLabel!
    @IBOutlet var buttonRows: [UIStackView]!
    @IBOutlet var digitButtons: [UIButton]!
    @IBOutlet var binaryOperationButtons: [UIButton]!
    @IBOutlet var unaryOperationButtons: [UIButton]!
    @IBOutlet var constantButtons: [UIButton]!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var squareRootButton: UIButton! // Is also in unaryOperationButtons
    @IBOutlet weak var equalsButton: UIButton!
    @IBOutlet weak var floatingPointButton: UIButton! {
        didSet {
            floatingPointButton.setTitle(localDecimalSeparator, for: .normal)
        }
    }
    
    // MARK: Initial Setup
    override func viewDidLoad() {
        // hidableViews = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, equalsButton, floatingPointButton]
        setup()
    }
    
    private func setup() {
        adaptView(to: .start)
    }
    
    // MARK: - IBActions
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        
        if userIsInTheMiddleOfTyping && textCurrentlyInDisplay != "0" { // Because you can start with a 0
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
        
        adaptView(to: .digit)
    }
    
    @IBAction func touchFloatingPoint(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if !(display.text?.contains(localDecimalSeparator))! {
                display.text = display.text! + localDecimalSeparator
            }
        } else {
            display.text = "0\(localDecimalSeparator)"
            userIsInTheMiddleOfTyping = true
        }
        
        adaptView(to: .floatingPoint)
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let displayValue = displayValue {
                display.text = displayValue.decimalFormat
                brain.setOperand(displayValue)
            }
            userIsInTheMiddleOfTyping = false
        }
        brain.performOperation(sender.currentTitle!)
        if let result = brain.result {
            displayValue = result
        }
        descriptionLabel.text = brain.description
        
        // Show and hide views adapting to the situation
        if sender == equalsButton {
            adaptView(to: .equals)
        } else if constantButtons.contains(sender) {
            adaptView(to: .constant)
        } else if unaryOperationButtons.contains(sender) {
            adaptView(to: .unary)
        } else if binaryOperationButtons.contains(sender) {
            adaptView(to: .binary)
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        setup()
        brain = CalculatorBrain()
        display.text = "0"
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping else { return }
        
        // Remove last character. If it's a floating point, show the floating point button again.
        if let removedCharacter = display.text?.characters.removeLast(),
            String(removedCharacter) == localDecimalSeparator { adaptView(to: .digit) }
        
        if display.text == "" {
            display.text = "0"
            userIsInTheMiddleOfTyping = false
            adaptView(to: .deletedLastDigit)
        }
    }
    
    // MARK: - Showing and Hiding Views
    private let animationDuration = 0.25
    
    private enum Situation {
        case start
        
        case digit
        case floatingPoint
        
        case constant
        case unary
        case binary
        case equals
        
        case deletedLastDigit
    }
    
    private func adaptView(to situation: Situation) {
        UIView.animate(withDuration: animationDuration) {
            self.digitButtons.forEach { $0.isHidden = !self.shouldShowDigitButtons(in: situation) }
            self.binaryOperationButtons.forEach { $0.isHidden = !self.shouldShowBinaryOperationButtons(in: situation) }
            self.unaryOperationButtons.forEach { $0.isHidden = !self.shouldShowUnaryOperationButtons(in: situation) }
            self.constantButtons.forEach { $0.isHidden = !self.shouldShowConstantButtons(in: situation) }
            self.floatingPointButton.isHidden = !self.shouldShowFloatingPointButton(in: situation)
            self.clearButton.isHidden = !self.shouldShowClearButton(in: situation)
            self.equalsButton.isHidden = !self.shouldShowEqualsButton(in: situation)
            
            if (self.displayValue?.isLess(than: 0)) ?? true {
                self.squareRootButton.isHidden = true
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

//    private func adaptView(to situation: Situation) {
//        let isPending = brain.resultIsPending
//        var viewsToShow = [UIView]()
//        
//        switch situation {
//            
//        case .start:
//            viewsToShow = digitButtons + constantButtons + [floatingPointButton]
//            
//        case .digit:
//            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + [clearButton]
//            if !(display.text?.contains(localDecimalSeparator))! {
//                viewsToShow.append(floatingPointButton)
//            }
//            if isPending {
//                viewsToShow.append(equalsButton)
//            }
//            
//        case .floatingPoint:
//            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + [clearButton]
//            if isPending {
//                viewsToShow.append(equalsButton)
//            }
//            
//        case .constant:
//            viewsToShow = binaryOperationButtons + unaryOperationButtons + [clearButton]
//            if isPending {
//                viewsToShow.append(equalsButton)
//            }
//            
//        case .unary:
//            if isPending {
//                viewsToShow = binaryOperationButtons + unaryOperationButtons + [clearButton, equalsButton]
//            } else {
//                viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
//            }
//            if (displayValue?.isLess(than: 0)) ?? false {
//                viewsToShow.remove(at: viewsToShow.index(of:squareRootButton)!)
//            }
//            
//        case .binary:
//            viewsToShow = digitButtons + constantButtons + [clearButton, floatingPointButton]
//        
//        case .equals:
//            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
//            if (displayValue?.isLess(than: 0)) ?? false {
//                viewsToShow.remove(at: viewsToShow.index(of:squareRootButton)!)
//            }
//        
//        case .deletedLastDigit:
//            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
//            if isPending {
//                viewsToShow.append(equalsButton)
//            }
//        }
//        
//        showOnly(viewsToShow)
//    }
//    
//    // helper method for adaptView(to:)
//    private func showOnly(_ viewsToShow: [UIView]) {
//        for hidableView in hidableViews {
//            let shouldBeHidden = !viewsToShow.contains(hidableView)
//            // This loop is necessary because, for some reason, isHidden is not always successfully set to shouldBeHidden. More precisely: The equalsButton is only made visible after about 3 times. No problems with other buttons. I can't find a difference between the equalsButton and other buttons, though. I thought about deleting and recreating the equalsButton. Maybe I'll try that later and see if I can get rid of this loop then.
//            while hidableView.isHidden != shouldBeHidden {
//                UIView.animate(withDuration: animationDuration) {
//                    hidableView.isHidden = shouldBeHidden
//                }
//            }
//        }
//        showOnlyNonEmptyStackViews()
//    }
//    
//    // helper method for showOnly(_:)
//    private func showOnlyNonEmptyStackViews() {
//        for stackView in buttonRows {
//            UIView.animate(withDuration: animationDuration) {
//                stackView.isHidden = self.stackViewWillBeVisuallyEmpty(stackView)
//            }
//        }
//    }
//    
//    // helper method for showOnlyNonEmptyStackViews()
//    private func stackViewWillBeVisuallyEmpty(_ stackView: UIStackView) -> Bool {
//        for view in stackView.subviews {
//            if !view.isHidden { return false }
//        }
//        return true
//    }

