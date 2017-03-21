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
    private var hiddenViews = [UIView]()
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
    @IBOutlet weak var firstRow: UIStackView!
    @IBOutlet var digitButtons: [UIButton]!
    @IBOutlet var binaryOperationButtons: [UIButton]!
    @IBOutlet var unaryOperationButtons: [UIButton]!
    @IBOutlet var constantButtons: [UIButton]!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var squareRootButton: UIButton! // Is also in unaryOperationButtons
    @IBOutlet weak var equalsButton: UIButton!
    @IBOutlet weak var display: InsetLabel!
    @IBOutlet weak var descriptionLabel: InsetLabel!
    @IBOutlet weak var floatingPointButton: UIButton! {
        didSet {
            floatingPointButton.setTitle(localDecimalSeparator, for: .normal)
        }
    }
    
    // MARK: Startup
    override func viewDidLoad() {
        setup()
    }
    
    private func setup() {
        hide(firstRow)
        hide(binaryOperationButtons)
        hide(unaryOperationButtons)
        hide(clearButton)
        hide(equalsButton)
        showAll(except: binaryOperationButtons + unaryOperationButtons + [clearButton, equalsButton])
    }
    
    // MARK: - IBActions
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
            
            // When the user starts typing a number, the constant buttons stop making sense. All operation buttons start making sense. = only makes sense when an operation is pending.
            hide(constantButtons)
            showAll(except: constantButtons + [equalsButton])
            if brain.evaluate().isPending {
                show(equalsButton)
            }
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
        
        // When the user touches the floating point, another floating point wouldn't make sense.
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
        
        // If isPending, hide all binary and unary operation buttons and the = button
        if brain.evaluate().isPending {
            hide(binaryOperationButtons)
            hide(unaryOperationButtons)
            hide(equalsButton)
        
        // If = is pressed, show all buttons
        } else if sender == equalsButton {
            show(hiddenViews)
        
        // If a constant was pressed, other constant buttons, digit buttons and floating point buttons don't make sense.
        } else if constantButtons.contains(sender) {
            hide(constantButtons)
            hide(digitButtons)
            hide(floatingPointButton)
            showAll(except: constantButtons + digitButtons + [floatingPointButton, equalsButton])
            if brain.evaluate().isPending {
                show(equalsButton)
            } else {
                hide(equalsButton)
            }
        
        // If a unary operation button has been pressed, hide digits and show equals
        } else if unaryOperationButtons.contains(sender) {
            hide(constantButtons)
            hide(digitButtons)
            hide(floatingPointButton)
            showAll(except: constantButtons + digitButtons + [floatingPointButton, equalsButton])
            if brain.evaluate().isPending {
                show(equalsButton)
            } else {
                hide(equalsButton)
            }
            
        // If a binary operation button is pressed, show digits
        } else if binaryOperationButtons.contains(sender) {
            show(digitButtons) // TODO: Doesn't work. I think a different case is executed first so this never gets called. I must clean this whole thing up.
        }
        
        // If the display now shows a negative number, hide √
        if (displayValue?.isLess(than: 0)) ?? false {
            hide(squareRootButton)
        }
    }

    @IBAction func clear(_ sender: UIButton) {
        setup()
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
    
    // MARK: - Showing and Hiding Views
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
    
//    private func hideAll(except viewsToKeepVisible: [UIView]) {
//        hiddenViews.forEach {
//            if !viewsToKeepVisible.contains($0) {
//                show($0)
//            }
//        }
//    }
    
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
    
    private func showAll(except viewsToKeepHidden: [UIView]) {
        hiddenViews.forEach {
            if !viewsToKeepHidden.contains($0) {
                show($0)
            }
        }
    }
}

