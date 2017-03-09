//
//  Double+Extension.swift
//  Calculator
//
//  Created by Lennart Wisbar on 08.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

extension Double {
    
    var decimalFormat: String {
        let formatter = NumberFormatter()

        let string = String(self)
        if string.hasSuffix(".0") || string.hasSuffix(".") {
            formatter.numberStyle = .none
        } else {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 6
        }
        
        let number = NSNumber(value: self)
        return formatter.string(from: number)!
    }
    
//    var scientificFormat: String {
//        let formatter = NumberFormatter()
//        
//        formatter.numberStyle = .scientific
//        formatter.maximumFractionDigits = 6
//        
//        let number = NSNumber(value: self)
//        return formatter.string(from: number)!
//    }
}
