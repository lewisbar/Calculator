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
    private var hidableViews = [UIView]()
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
        hidableViews = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, equalsButton, floatingPointButton]
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
        let animationDuration = 0.25
        let isPending = brain.resultIsPending
        var viewsToShow = [UIView]()
        
        // helper method for adaptView(to:)
        func showOnly(_ viewsToShow: [UIView]) {
            
            // helper method for showOnly(_:)
            func showOnlyNonEmptyStackViews() {
                
                // helper method for showOnlyNonEmptyStackViews()
                func stackViewWillBeVisuallyEmpty(_ stackView: UIStackView) -> Bool {
                    for view in stackView.subviews {
                        if !view.isHidden { return false }
                    }
                    return true
                }
                
                // implementation of showOnlyNonEmptyStackViews()
                for stackView in buttonRows {
                    UIView.animate(withDuration: animationDuration) {
                        stackView.isHidden = stackViewWillBeVisuallyEmpty(stackView)
                    }
                }
            }
            
            // implementation of showOnly(_:)
            for hidableView in hidableViews {
                let shouldBeHidden = !viewsToShow.contains(hidableView)
                // This loop is necessary because, for some reason, isHidden is not always successfully set to shouldBeHidden. More precisely: The equalsButton is only made visible after about 3 times. No problems with other buttons. I can't find a difference between the equalsButton and other buttons, though. I thought about deleting and recreating the equalsButton. Maybe I'll try that later and see if I can get rid of this loop then.
                while hidableView.isHidden != shouldBeHidden {
                    UIView.animate(withDuration: animationDuration) {
                        hidableView.isHidden = shouldBeHidden
                    }
                }
            }
            showOnlyNonEmptyStackViews()
        }
        
        // implementation of adaptView(to:)
        switch situation {
        case .start:
            viewsToShow = digitButtons + constantButtons + [floatingPointButton]
        case .digit:
            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + [clearButton]
            if !(display.text?.contains(localDecimalSeparator))! {
                viewsToShow.append(floatingPointButton)
            }
            if isPending {
                viewsToShow.append(equalsButton)
            }
        case .floatingPoint:
            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + [clearButton]
            if isPending {
                viewsToShow.append(equalsButton)
            }
        case .constant:
            viewsToShow = binaryOperationButtons + unaryOperationButtons + [clearButton]
            if isPending {
                viewsToShow.append(equalsButton)
            }
        case .unary:
            if isPending {
                viewsToShow = binaryOperationButtons + unaryOperationButtons + [clearButton, equalsButton]
            } else {
                viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
            }
            if (displayValue?.isLess(than: 0)) ?? false {
                viewsToShow.remove(at: viewsToShow.index(of:squareRootButton)!)
            }
        case .binary:
            viewsToShow = digitButtons + constantButtons + [clearButton, floatingPointButton]
        case .equals:
            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
            if (displayValue?.isLess(than: 0)) ?? false {
                viewsToShow.remove(at: viewsToShow.index(of:squareRootButton)!)
            }
        case .deletedLastDigit:
            viewsToShow = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [clearButton, floatingPointButton]
            if isPending {
                viewsToShow.append(equalsButton)
            }
        }
        showOnly(viewsToShow)
    }
}

