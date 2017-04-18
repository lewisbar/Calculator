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
        if let result = brain.evaluate().result {
            displayValue = result
        }
        descriptionLabel.text = brain.evaluate().description
        
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
        adaptView(to: .start)
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
    
    // MARK: M
    private var m: Dictionary<String, Double>?
    
    @IBAction func setM(_ sender: UIButton) {
        m = ["M":displayValue!]
        displayValue = brain.evaluate(using: m).result
    }

    @IBAction func m(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        displayValue = brain.evaluate(using: m).result
    }
    
    // MARK: - Detect Shake Gesture to Toggle Adaptive Interface
    private var uiIsAdaptive = true
    private var currentSituation = Situation.start
    override var canBecomeFirstResponder: Bool { return true }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            uiIsAdaptive = !uiIsAdaptive
            adaptView(to: currentSituation)
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
            
            // This loop is a workaround for a bug I don't understand yet. The equals button seems equal (pun intended) to all the other buttons, yet it's the only one that needs three calls to finally show up again. I tried changing the order of the buttons, deleting and recreating the button and changing its colors to be exactly like the others. It all made no difference.
            while self.equalsButton.isHidden == self.shouldShowEqualsButton(in: situation) {
                self.equalsButton.isHidden = !self.shouldShowEqualsButton(in: situation)
            }
            
            
            if self.uiIsAdaptive && (self.displayValue?.isLess(than: 0)) ?? false {
                self.squareRootButton.isHidden = true
            }
            
            self.showOnlyNonEmptyStackViews()
        }
    }
    
    private func adaptViewToNonAdaptive() {
        UIView.animate(withDuration: animationDuration) {
            self.digitButtons.forEach { $0.isHidden = false }
            self.binaryOperationButtons.forEach { $0.isHidden = false }
            self.unaryOperationButtons.forEach { $0.isHidden = false }
            self.constantButtons.forEach { $0.isHidden = false }
            self.floatingPointButton.isHidden = false
            self.clearButton.isHidden = false
            
            // This loop is a workaround for a bug I don't understand yet. The equals button seems equal (pun intended) to all the other buttons, yet it's the only one that needs three calls to finally show up again. I tried changing the order of the buttons, deleting and recreating the button and changing its colors to be exactly like the others. It all made no difference.
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

