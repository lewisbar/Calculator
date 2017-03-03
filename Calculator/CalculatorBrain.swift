//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

struct CalculatorBrain {

    private var calculation: (accumulator: Double?, description: String) = (nil, " ")
    
    var result: Double? {
        return calculation.accumulator
    }
    
    var description: String {
        return calculation.description
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
    
    mutating func performOperation(_ symbol: String) {
        let operation = operations[symbol]!
        
        switch operation {
        case .constant(let value):
            //if !resultIsPending && !accumulatorIsHoldingResult { updateDescription() }
//            let oldDescription = calculation.description
//            let newDescription = resultIsPending ?
//                                oldDescription + String(value)
//                                : String(value)
//            calculation = (value, newDescription)
            //accumulatorIsHoldingResult = true
            if accumulatorIsHoldingResult {
                calculation.description = " "
                //accumulatorIsHoldingResult = false
            }
            calculation.accumulator = value
        case .unary(let function):
            if let accumulator = calculation.accumulator {
                let oldDescription = calculation.description
                let newDescription = resultIsPending ?
                                "\(oldDescription)\(symbol)(\(accumulator)) "
                                : "\(symbol)(\(oldDescription)) "
                let newAccumulator = function(accumulator)
                calculation = (newAccumulator, newDescription)
                accumulatorIsHoldingResult = true
            }
        case .binary(let function):
            if !accumulatorIsHoldingResult { updateDescription() }
            //accumulatorIsHoldingResult = false
            performBinaryOperation()
            if let accumulator = calculation.accumulator {
                calculation.description.append(symbol)
                pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator)
            }
        case .equals:
            if resultIsPending && !accumulatorIsHoldingResult { updateDescription() }
            performBinaryOperation()
            accumulatorIsHoldingResult = true
        }
    }
    
    private mutating func updateDescription() {
        if let accumulator = calculation.accumulator {
            calculation.description.append("\(accumulator)")
        }
    }
    
    private mutating func performBinaryOperation() {
        if let accumulator = calculation.accumulator, resultIsPending {
            calculation.accumulator = (pendingBinaryOperation?.perform(with: accumulator))!
            pendingBinaryOperation = nil
            accumulatorIsHoldingResult = true
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var resultIsPending: Bool {
        return (pendingBinaryOperation != nil)
    }
    private var accumulatorIsHoldingResult = false
    
    private struct PendingBinaryOperation {
        let operation: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return operation(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        //calculation = (operand, (calculation.description + "\(operand)"))   // Description nur updaten, wenn ein operator oder = gedrückt wurde?
//        if accumulatorIsHoldingResult {
//            calculation.description = " "
//            accumulatorIsHoldingResult = false
//        }
        calculation.accumulator = operand
    }
    
}
