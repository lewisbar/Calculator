//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    // MARK: - Public API
    var result: Double? {
        return calculation.accumulator
    }
    
    var description: String { // Shows what led to the current result
        return calculation.description
    }
    
    mutating func setOperand(_ operand: Double) {
        let oldDescription = calculation.description
        let newDescription = resultIsPending ? "\(oldDescription) \(operand)" : "\(operand)"
        calculation = (accumulator: operand, description: newDescription)
    }
    
    mutating func performOperation(_ symbol: String) {
        let operation = operations[symbol]!
        
        switch operation {
        case .constant(let value):
            let oldDescription = calculation.description
            let newDescription = resultIsPending ? "\(oldDescription) \(symbol)" : "\(symbol)"
            calculation = (accumulator: value, description: newDescription)
        case .unary(let function):
            if let accumulator = calculation.accumulator {
                let oldDescription = calculation.description
                let newDescription = resultIsPending ?
                                oldDescription.surroundingLastWord(with: "\(symbol)(", and: ")")
                                : "\(symbol)(\(oldDescription))"
                let newAccumulator = function(accumulator)
                calculation = (newAccumulator, newDescription)
            }
        case .binary(let function):
            if resultIsPending {
                performBinaryOperation()
            }
            if let accumulator = calculation.accumulator {
                calculation.description = "\(calculation.description) \(symbol)"
                pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator)
            }
        case .equals:
            if resultIsPending {
                performBinaryOperation()
            }
        }
    }
    
    // MARK: - Private Implementation
    private var calculation: (accumulator: Double?, description: String) = (nil, " ")
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var resultIsPending: Bool {
        return (pendingBinaryOperation != nil)
    }

    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    private let operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "sin": Operation.unary(sin),
        "cos": Operation.unary(cos),
        "tan": Operation.unary(tan),
        "√": Operation.unary(sqrt),
        "±": Operation.unary(-),
        "×": Operation.binary(*),
        "÷": Operation.binary(/),
        "+": Operation.binary(+),
        "−": Operation.binary(-),
        "^": Operation.binary(pow),
        "=": Operation.equals
    ]
    
    private struct PendingBinaryOperation {
        let operation: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return operation(firstOperand, secondOperand)
        }
    }

    private mutating func performBinaryOperation() {
        if let accumulator = calculation.accumulator {
            calculation.accumulator = (pendingBinaryOperation?.perform(with: accumulator))!
            pendingBinaryOperation = nil
        }
    }
    
}
