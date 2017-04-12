//
//  HidableView.swift
//  Calculator
//
//  Created by Lennart Wisbar on 10.04.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import UIKit

class HidableView: UIView {

    var shouldShow: Dictionary<Situation, Bool> = [
        .start: true,
        .digit: true,
        .floatingPoint: true,
        .constant: true,
        .unary: true,
        .binary: true,
        .equals: true,
        .deletedLastDigit: true
    ]

}
