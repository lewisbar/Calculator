//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    //private var accumulator: Double?
    //var description = " "
    //private var calculation: (Double?, String) = (accumulator: nil, description: " ")
    private struct Calculation {
        var accumulator: Double?
        var description = " "
        
        mutating func setOperand(_ operand: Double) {
            accumulator = operand
            description.append("\(operand) ")
        }
        
        mutating func setBinaryResult(_ result: Double) {
            accumulator = result
        }
        
        mutating func setPendingBinaryOperation(_ symbol: String) {
            description.append("\(symbol) ")
        }
        
        mutating func setUnaryOperation(_ symbol: String, result: Double, binaryResultIsPending: Bool) {
            if binaryResultIsPending {
                description.append("\(symbol)(\(accumulator!)) ")
            } else {
                description = "\(symbol)(\(description)) "
            }
            accumulator = result
        }
        
        mutating func setConstant(withSymbol symbol: String, value: Double) {
            accumulator = value
            description.append(" \(symbol) ")
        }
    }
    
    private var calculation = Calculation()
    
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
            calculation.setConstant(withSymbol: symbol, value: value)
        case .unary(let function):
            if let accumulator = calculation.accumulator {
                calculation.setUnaryOperation(symbol, result: function(accumulator), binaryResultIsPending: resultIsPending)
            }
        case .binary(let function):
            calculation.setPendingBinaryOperation(symbol)
            performBinaryOperation()
            if let accumulator = calculation.accumulator {
                pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator)
            }
        case .equals:
            performBinaryOperation()
        }
    }
    
    private mutating func performBinaryOperation() {
        if let accumulator = calculation.accumulator, resultIsPending {
            calculation.setBinaryResult((pendingBinaryOperation?.perform(with: accumulator))!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    private var resultIsPending: Bool {
        return (pendingBinaryOperation != nil)
    }
    
    private struct PendingBinaryOperation {
        let operation: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return operation(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        calculation.setOperand(operand)
    }
    
}
