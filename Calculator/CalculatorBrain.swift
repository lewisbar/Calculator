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
        "^": Operation.binary(pow)
    ]
    
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol] else {
            return
        }
        switch operation {
        case .constant(let value):
            accumulator = value
        case .unary(let function):
            if accumulator != nil {
                accumulator = function(accumulator!)
            }
        case .binary(let function):
            break
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
}
