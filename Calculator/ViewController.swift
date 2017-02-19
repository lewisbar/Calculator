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
            var stringValue = String(newValue)
            if stringValue.hasSuffix(".0") {
                stringValue = stringValue.substring(to: stringValue.index(stringValue.endIndex, offsetBy: -2))
            }
            display.text = stringValue
        }
    }
    
    @IBOutlet weak var display: UILabel!
    
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
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        brain.performOperation(sender.currentTitle!)
        if let result = brain.result {
            displayValue = result
        }
    }

    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        userIsInTheMiddleOfTyping = false
    }
}

