//
//  LogicFunction.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

// Simple definition of a logic function
typealias LogicFunction = ((_ inputs: [Signal]) -> [StandardLogicValue])

extension Collection where Element == Signal {
    // MARK: - Signal Composition
    var contaisSingleBitSignalsOnly: Bool { return self.filter{ $0.numberOfBits != 1 }.isEmpty }
    var containsSameLengthSignalsOnly: Bool {
        if let numberOfBits = self.first?.numberOfBits {
            return self.filter{ $0.numberOfBits != numberOfBits }.isEmpty
        }
        return false
    }
    
    // MARK: - Tautology & Satisfiability
    var allSignalsContainOnlyPositiveBits: Bool { return self.filter{ $0.bits.contains(.negative) }.isEmpty }
    var allSignalsContainOnlyNegativeBits: Bool { return self.filter{ $0.bits.contains(.positive) }.isEmpty }
}


// List of builtin logic functions
struct LogicFunctions {
    static let and: LogicFunction = { (_ inputs: [Signal]) -> [StandardLogicValue] in
        if( inputs.count == 1 && inputs.first!.numberOfBits != 0 ) {
            print("Warning - Perfoming Single Signal Operation")
            return inputs.allSignalsContainOnlyPositiveBits ? Array<StandardLogicValue>(repeating: .positive, count: inputs.first!.numberOfBits) : Array<StandardLogicValue>(repeating: .negative, count: inputs.first!.numberOfBits) //.positive : .negative
        } else if( inputs.contaisSingleBitSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return [.positive]
            }
        } else if( inputs.containsSameLengthSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return Array<StandardLogicValue>(repeating: .positive, count: inputs.first!.numberOfBits)
            } else {
                // TODO - Improve This
                return Array<StandardLogicValue>(repeating: .negative, count: inputs.first!.numberOfBits)
            }
        }
        return [.negative]
    }
//    static let or: LogicFunctions = { (_ inputs: [Signal]) -> StandardLogicValue in
//        if( inputs.count == 1 ) {
//            print("Warning - Perfoming Single Signal Operation")
//            return inputs.allSignalsContainOnlyPositiveBits ? .positive : .negative
//        } else if( inputs.contaisSingleBitSignalsOnly ) {
//            i
//        }
//    }
    
}
