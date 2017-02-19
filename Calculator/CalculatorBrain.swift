//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Lennart Wisbar on 18.02.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double?
    
    var result: Double? {
        get {
            return accumulator
        }
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
        "±": Operation.unary({ -$0 }),
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
            accumulator = value
        case .unary(let function):
            if accumulator != nil {
                accumulator = function(accumulator!)
            }
        case .binary(let function):
            if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(operation: function, firstOperand: accumulator!)
                accumulator = nil
            }
        case .equals:
            if accumulator != nil && pendingBinaryOperation != nil {
                accumulator = pendingBinaryOperation?.perform(with: accumulator!)
                pendingBinaryOperation = nil
            }
        }
    }
    
    var pendingBinaryOperation: PendingBinaryOperation?
    
    struct PendingBinaryOperation {
        let operation: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return operation(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
}
