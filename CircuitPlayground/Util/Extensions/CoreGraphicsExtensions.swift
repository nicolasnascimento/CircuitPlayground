//
//  CoreGraphicsExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

extension CGSize {
    
    // MARK: - Convenience initialization for creating a square
    init(side: CGFloat) {
        self.init(width: side, height: side)
    }
}

// MARK: - CGFloat operations
extension CGFloat {
    
    static func *(lhs: CGFloat, rhs: Double) -> CGFloat {
        return lhs*CGFloat(rhs)
    }
}

extension Double {
    static func +=(lhs: inout Double, rhs: Int) {
        lhs = lhs + Double(rhs)
    }
    static func +(lhs: Double, rhs: Int) -> Double {
        return lhs + Double(rhs)
    }
    static func +(lhs: Int, rhs: Double) -> Double {
        return Double(lhs) + rhs
    }
}

