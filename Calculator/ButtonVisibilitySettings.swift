//
//  ButtonVisibilitySettings.swift
//  Calculator
//
//  Created by Lennart Wisbar on 20.05.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

extension CalculatorVC {
    // MARK: - Button Visibility Settings
    func shouldShowDigitButtons(in situation: Situation) -> Bool {
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
    
    func shouldShowBinaryOperationButtons(in situation: Situation) -> Bool {
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
    
    func shouldShowUnaryOperationButtons(in situation: Situation) -> Bool {
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
    
    func shouldShowConstantButtons(in situation: Situation) -> Bool {
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
    
    func shouldShowFloatingPointButton(in situation: Situation) -> Bool {
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
    
    func shouldShowClearButton(in situation: Situation) -> Bool {
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
    
    func shouldShowEqualsButton(in situation: Situation) -> Bool {
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
