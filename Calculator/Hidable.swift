//
//  Hidable.swift
//  Calculator
//
//  Created by Lennart Wisbar on 06.04.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

protocol Hidable {
    var shouldShow: Dictionary<Situation, Bool> { get set }
}

enum Situation {
    case start
    
    case digit
    case floatingPoint
    
    case constant
    case unary
    case binary
    case equals
    
    case deletedLastDigit
}
