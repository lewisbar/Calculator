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
    //private var hiddenViews = [UIView]()
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
    @IBOutlet weak var firstRow: UIStackView!
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
        hidableViews = digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [firstRow, clearButton, equalsButton, floatingPointButton]
        setup()
    }
    
    private func setup() {
        adaptView(to: .start)
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
            String(removedCharacter) == localDecimalSeparator { adaptView(to: .deletedFloatingPoint) }
        
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
        
        case deletedFloatingPoint
        case deletedLastDigit
    }
    
    private func adaptView(to situation: Situation) {
        let isPending = brain.evaluate().isPending
        
        func showOnly(_ viewsToShow: [UIView]) {
            for hidableView in hidableViews {
                let shouldBeShown = viewsToShow.contains(hidableView)
                UIView.animate(withDuration: 0.5) { hidableView.isHidden = shouldBeShown }
            }
        }
        
        func makeVisible(_ view: UIView) {
            UIView.animate(withDuration: 0.5) { view.isHidden = false }
        }
        
        func hide(_ view: UIView) {
            UIView.animate(withDuration: 0.5) { view.isHidden = true }
        }
        
        switch situation {
        case .start:
            showOnly(digitButtons + constantButtons)
        case .digit:
            if isPending {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton, equalsButton, floatingPointButton])
            } else {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton, floatingPointButton])
            }
        case .floatingPoint:
            if isPending {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton, equalsButton])
            } else {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton])
            }
        case .constant:
            if isPending {
                showOnly(binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton, equalsButton])
            } else {
                showOnly(binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton])
            }
        case .unary:
            if isPending {
                showOnly(binaryOperationButtons + unaryOperationButtons + [firstRow, clearButton, equalsButton, floatingPointButton])
            } else {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [firstRow, clearButton, floatingPointButton])
            }
            if (displayValue?.isLess(than: 0)) ?? false {
                hide(squareRootButton)
            }
        case .binary:
            showOnly(digitButtons + constantButtons + [clearButton, floatingPointButton])
        case .equals:
            showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [firstRow, clearButton, floatingPointButton])
            if (displayValue?.isLess(than: 0)) ?? false {
                hide(squareRootButton)
            }
        case .deletedFloatingPoint:
            makeVisible(floatingPointButton)
        case .deletedLastDigit:
            if isPending {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [firstRow, clearButton, equalsButton, floatingPointButton])
            } else {
                showOnly(digitButtons + binaryOperationButtons + unaryOperationButtons + constantButtons + [firstRow, clearButton, floatingPointButton])
            }
        }
    }
    
//    private func hide(_ view: UIView) {
//        if !hiddenViews.contains(view) {
//            UIView.animate(withDuration: 0.5) { view.isHidden = true }
//            hiddenViews.append(view)
//        }
//    }
    
//    private func hide(_ views: [UIView]) {
//        views.forEach {
//            hide($0)
//        }
//    }
    
//    private func hideAll(except viewsToKeepVisible: [UIView]) {
//        hiddenViews.forEach {
//            if !viewsToKeepVisible.contains($0) {
//                show($0)
//            }
//        }
//    }
    
//    private func show(_ view: UIView) {
//        if hiddenViews.contains(view) {
//            UIView.animate(withDuration: 0.5) { view.isHidden = false }
//            hiddenViews.remove(at: hiddenViews.index(of: view)!)
//        }
//    }
    
//    private func show(_ views: [UIView]) {
//        views.forEach {
//            show($0)
//        }
//    }
//    
//    private func showAll(except viewsToKeepHidden: [UIView]) {
//        hiddenViews.forEach {
//            if !viewsToKeepHidden.contains($0) {
//                show($0)
//            }
//        }
//    }
}

