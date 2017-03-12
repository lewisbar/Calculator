//
//  ViewController.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {

    private var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    private var displayValue: Double? {
        get {
            return Double(display.text!)
        }
        set {
            display.text = newValue?.decimalFormat
        }
    }
    
    @IBOutlet weak var display: InsetLabel! {
        didSet {
            display.insets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            display.layer.cornerRadius = 5
            display.clipsToBounds = true
        }
    }
    @IBOutlet weak var descriptionLabel: InsetLabel! {
        didSet {
            descriptionLabel.insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            descriptionLabel.layer.cornerRadius = 5
            descriptionLabel.clipsToBounds = true
            //descriptionLabel.fontSizeShouldBeLabelHeightMinus = 4
        }
    }
    
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
    }

    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping else { return }
        display.text?.characters.removeLast()
        if display.text == "" {
            display.text = "0"
            userIsInTheMiddleOfTyping = false
        }
    }
}

