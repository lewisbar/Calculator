//
//  String+Extension.swift
//  Calculator
//
//  Created by Lennart Wisbar on 08.03.17.
//  Copyright © 2017 Lennart Wisbar. All rights reserved.
//

import Foundation

extension String {
    public func replacingSuffix(_ oldSuffix: String, with newSuffix: String) -> String {
        let start = self.index(self.endIndex, offsetBy: -oldSuffix.characters.count)
        let end = self.endIndex
        let range = start..<end
        return self.replacingCharacters(in: range, with: newSuffix)
    }
}
