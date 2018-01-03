//
//  LogicFunction.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct LogicFunctionDescriptor {
    var logicDescriptor: LogicDescriptor.LogicOperation
    var logicFunction: LogicFunction
}

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
    
    // MARK: - Logic Operations
    var performingAndOfSignals: [StandardLogicValue] {
        return self.reduce([StandardLogicValue](), {
            var storage = $0
            if( storage.isEmpty ) {
                storage.append(contentsOf: $1.bits)
            } else {
                var newStorage = [StandardLogicValue]()
                for (index, bit) in $1.bits.enumerated() {
                    newStorage.append(storage[index] & bit)
                }
                storage = newStorage
            }
            return storage
        })
    }
    var performingOrOfSignals: [StandardLogicValue] {
        return self.reduce([StandardLogicValue](), {
            var storage = $0
            if( storage.isEmpty ) {
                storage.append(contentsOf: $1.bits)
            } else {
                var newStorage = [StandardLogicValue]()
                for (index, bit) in $1.bits.enumerated() {
                    newStorage.append(storage[index] | bit)
                }
                storage = newStorage
            }
            return storage
        })
    }
    var performingNotOfSignals: [StandardLogicValue] {
        return self.first?.bits.map{ return !$0 } ?? []
    }
}


// List of builtin logic functions
enum LogicFunctions {
    
    // MARK: - Standard Logic Operation
    static let and: LogicFunction = { (_ inputs: [Signal]) -> [StandardLogicValue] in
        if( inputs.isEmpty ) {
            print("Warning - Perfoming operation (and) without inputs")
            return []
        } else if( inputs.count == 1 && inputs.first!.numberOfBits != 0 ) {
            print("Warning - Perfoming single signal operation (and)")
            return inputs.first!.bits
        } else if( inputs.contaisSingleBitSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return [.positive]
            } else {
                return inputs.performingAndOfSignals
            }
        } else if( inputs.containsSameLengthSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return [StandardLogicValue](repeating: .positive, count: inputs.first!.numberOfBits)
            } else {
                return inputs.performingAndOfSignals
            }
        }
        return []
    }
    static let none: LogicFunction = { (_ inputs: [Signal]) -> [StandardLogicValue] in
        if( inputs.isEmpty ) {
            print("Warning - Perfoming operation (none) without inputs")
            return []
        } else {
            return inputs.first!.bits
        }
    }
    static let or: LogicFunction = { (_ inputs: [Signal]) -> [StandardLogicValue] in
        if( inputs.isEmpty ) {
            print("Warning - Perfoming operation (or) without inputs")
            return []
        } else if( inputs.count == 1 && inputs.first!.numberOfBits != 0 ) {
            print("Warning - Perfoming single signal operation (or)")
            return inputs.first!.bits
        } else if( inputs.contaisSingleBitSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return [.positive]
            } else {
                return inputs.performingOrOfSignals
            }
        } else if( inputs.containsSameLengthSignalsOnly ) {
            if( inputs.allSignalsContainOnlyPositiveBits ) {
                return [StandardLogicValue](repeating: .positive, count: inputs.first!.numberOfBits)
            } else {
                return inputs.performingOrOfSignals
            }
        }
        return []
    }
    static let not: LogicFunction = { (_ inputs: [Signal]) -> [StandardLogicValue] in
        if( inputs.isEmpty ) {
            print("Warning - Perfoming operation (not) without inputs")
            return []
        } else if( inputs.count == 1 && inputs.first!.numberOfBits != 0 ) {
            print("Warning - Perfoming single signal operation (not)")
            return inputs.performingNotOfSignals
        }
        print("Error - Cannot perform multi entry signal operation (not)")
        return []
    }

    
}
