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
    private var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    
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
    
    private var hiddenViews = [UIView]()
    
    // MARK: - IBOutlets
    @IBOutlet weak var display: InsetLabel!

    @IBOutlet weak var descriptionLabel: InsetLabel!
    
    @IBOutlet weak var floatingPointButton: UIButton! {
        didSet {
            floatingPointButton.setTitle(localDecimalSeparator, for: .normal)
        }
    }
    
    @IBOutlet var binaryOperationButtons: [UIButton]!
    @IBOutlet var unaryOperationButtons: [UIButton]!
    @IBOutlet var constantButtons: [UIButton]!
    @IBOutlet weak var squareRootButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
            // Once there is a fresh number in the display, there is no need to hide any buttons anymore // TODO: That might be different for the memory label.
            show(hiddenViews)
        }
        
        
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
        hide(floatingPointButton)
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
        show(floatingPointButton)
        
        // If isPending, hide all binary and unary operation buttons
        if brain.evaluate().isPending {
            hide(binaryOperationButtons)
            hide(unaryOperationButtons)
        }
        
        // If = or a constant is pressed, show all buttons again
        if sender.currentTitle == "=" || constantButtons.contains(sender) {
            print("= or constant pressed")
            show(hiddenViews)
        }
        
        // If the display now shows a negative number, hide √
        if (displayValue?.isLess(than: 0)) ?? false {
            hide(squareRootButton)
        }
    }

    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = "0"
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
        show(hiddenViews)
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping else { return }
        
        // Remove last character. If it's a floating point, show the floating point button again.
        if let removedCharacter = display.text?.characters.removeLast(),
            String(removedCharacter) == localDecimalSeparator { show(floatingPointButton) }
        
        if display.text == "" {
            display.text = "0"
            userIsInTheMiddleOfTyping = false
        }
    }
    
    // MARK: Animations
    private func hide(_ view: UIView) {
        if !hiddenViews.contains(view) {
            UIView.animate(withDuration: 0.5) { view.isHidden = true }
            hiddenViews.append(view)
        }
    }
    
    private func hide(_ views: [UIView]) {
        views.forEach {
            hide($0)
        }
    }
    
    private func show(_ view: UIView) {
        if hiddenViews.contains(view) {
            UIView.animate(withDuration: 0.5) { view.isHidden = false }
            hiddenViews.remove(at: hiddenViews.index(of: view)!)
        }
    }
    
    private func show(_ views: [UIView]) {
        views.forEach {
            show($0)
        }
    }
    
    // TODO: show/hide all except ...
    // TODO: go through all occurrences of hiddenViews and look what really needs to be shown or hidden
    // TODO: look where else views should be shown or hidden
}

