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
    var brain = CalculatorBrain()
    private var userIsInTheMiddleOfTyping = false
    let localDecimalSeparator = (NSLocale.current.decimalSeparator as String?) ?? "."
    var displayValue: Double? {
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
    var uiIsAdaptive = true
    var currentSituation = Situation.start
    override var canBecomeFirstResponder: Bool { return true }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            uiIsAdaptive = !uiIsAdaptive
            adaptView(to: currentSituation)
        }
    }
}
