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
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        
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
