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
    @available(*, deprecated)
    var result: Double? {
        return evaluate().result // calculation.accumulator
    }
    
    @available(*, deprecated)
    var description: String { // Shows what led to the current result
        // let endSymbol = resultIsPending ? " ..." : " ="
        return evaluate().description // calculation.description + endSymbol
    }
    
    @available(*, deprecated)
    var resultIsPending: Bool {
        return evaluate().isPending // (pendingBinaryOperation != nil)
    }
    
    mutating func setOperand(_ operand: Double) {
        let oldDescription = calculation.description
        let newDescription = evaluate().isPending ? "\(oldDescription) \(operand.decimalFormat)" : "\(operand.decimalFormat)"
        calculation = (accumulator: operand, description: newDescription)
    }
    
    func setOperand(variable named: String) {
        // TODO
    }
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)
        -> (result: Double?, isPending: Bool, description: String) {
            // TODO
            let result: Double? = calculation.accumulator
            let isPending = pendingBinaryOperation != nil
            let endSymbol = isPending ? " ..." : " ="
            let description = calculation.description + endSymbol
            return (result, isPending, description)
    }
    
    mutating func performOperation(_ symbol: String) {
        // TODO: Multiplication and division should be performed first. This will probably be easier with the new structure that comes in Assignment 2.
        guard let operation = operations[symbol] else {
            print("Operation \(symbol) not supplied.")
            return
        }
        
        switch operation {
        case .constant(let value):
            let oldDescription = calculation.description
            let newDescription = evaluate().isPending ? "\(oldDescription) \(symbol)" : "\(symbol)"
            calculation = (accumulator: value, description: newDescription)
        case .unary(let function):
            if let accumulator = calculation.accumulator {
                let oldDescription = calculation.description
                let newDescription = evaluate().isPending ?
                                oldDescription.surroundingLastWord(with: "\(symbol)(", and: ")")
                                : "\(symbol)(\(oldDescription))"
                let newAccumulator = function(accumulator)
                calculation = (newAccumulator, newDescription)
            }
        case .binary(let function):
            if evaluate().isPending {
                performBinaryOperation()
            }
            if let accumulator = calculation.accumulator {
                calculation.description = "\(calculation.description) \(symbol)"
                // TODO: Don't allow multiple binary symbols in a row. This will probably be easier with the new structure that comes in Assignment 2.
                pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator)
            }
        case .equals:
            if evaluate().isPending {
                performBinaryOperation()
            }
        }
    }
    
    // MARK: - Private Implementation
    private var calculation: (accumulator: Double?, description: String) = (nil, " ")
    private var pendingBinaryOperation: PendingBinaryOperation?

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
