//
//  LogicDescriptor.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct LogicDescriptor: Equatable, Codable {
    enum LogicOperation: String, Hashable, Codable {
        case and
        case or
        case none
        case not
        case nand
        case nor
        case xor
        case xnor
        case mux
    }
    enum ElementType: String, Equatable, Codable {
        case combinational
        case sequential
        case connection
    }
    var elementType: ElementType
    var logicOperation: LogicOperation
    var inputs: [Input]
    var outputs: [Output]
}


extension Collection where Element == LogicDescriptor{
    /// Returns true if every outputs that is contained in the elements of the Collection
    /// are also present
    func checkIfOutputsAreEqual(to other: [Element]) -> Bool {
        for element in self {
            if !other.filter({ $0 == element }).isEmpty {
                return false
            }
        }
        return true
    }
    func deattachingOutputs() -> [Element] {
        return self.map{ Element(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: []) }
    }
}
