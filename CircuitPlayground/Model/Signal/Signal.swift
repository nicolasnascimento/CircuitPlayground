//
//  Signal.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

// Enumerate possible logic values
enum StandardLogicValue: String {
    case positive = "1"
    case negative = "0"
    
    // MARK: - Operators
    static public func &(lhs: StandardLogicValue, rhs: StandardLogicValue) -> StandardLogicValue {
        switch lhs {
        case .positive: return rhs
        case .negative: return .negative
        }
    }
    static public func |(lhs: StandardLogicValue, rhs: StandardLogicValue) -> StandardLogicValue {
        switch lhs {
        case .positive: return .positive
        case .negative: return rhs
        }
    }
    static public prefix func !(rhs: StandardLogicValue) -> StandardLogicValue {
        switch rhs {
        case .negative: return .positive
        case .positive: return .negative
        }
    }
}

// Describes the necessary properties for a Signal
protocol Signal {
    var numberOfBits: Int { get }
    var associatedId: String { get set }
    var bits: [StandardLogicValue] { get set }
}
