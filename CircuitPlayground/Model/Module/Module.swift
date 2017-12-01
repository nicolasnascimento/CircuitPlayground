//
//  Module.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct SignalKey: Signal {
    var numberOfBits: Int
    var associatedId: String
    var bits: [StandardLogicValue]
}

extension SignalKey: Hashable {
    var hashValue: Int {
        return self.numberOfBits.hashValue + self.associatedId.hashValue + self.bits.reduce(0, { $0 + $1.hashValue })
    }
    static func ==(lhs: SignalKey, rhs: SignalKey) -> Bool {
        return lhs.associatedId == rhs.associatedId
    }
}

protocol Module {
    
    // Entity description
    var inputs: [Signal] { get set }
    var outputs: [Signal] { get set }
    
    // Behaviour description
    var internalSignals: [Signal] { get set }
    var functions: [SignalKey: LogicFunction] { get set }
    var auxiliarModules: [Module] { get set }
}
