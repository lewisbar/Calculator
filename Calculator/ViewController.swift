//
//  ViewController.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let stringValue = String(newValue)
            display.text = formatForDisplay(stringValue)
        }
    }
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func touchFloatingPoint(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if !(display.text?.contains("."))! {
                display.text = display.text! + "."
            }
        } else {
            display.text = "0."
            userIsInTheMiddleOfTyping = true
        }
    }

    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            let stringValue = String(displayValue)
            display.text = formatForDisplay(stringValue)
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        brain.performOperation(sender.currentTitle!)
        if let result = brain.result {
            displayValue = result
        }
        descriptionLabel.text = brain.description
    }

    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    private func formatForDisplay(_ stringToFormat: String) -> String {
        var stringToFormat = stringToFormat
        if stringToFormat.hasSuffix(".0") {
            stringToFormat = stringToFormat.substring(to: stringToFormat.index(stringToFormat.endIndex, offsetBy: -2))
        } else if (stringToFormat.hasSuffix(".")) {
            let indexOfFloatingPoint = (stringToFormat.index(before: (stringToFormat.endIndex)))
            stringToFormat = stringToFormat.substring(to: indexOfFloatingPoint)
        }
        return stringToFormat
    }
}

