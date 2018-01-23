//
//  LogicDescriptor.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct LogicDescriptor: Codable {
    enum LogicOperation: String, Codable {
        case and
        case or
        case none
        case not
    }
    enum ElementType: String, Codable {
        case combinational
        case sequential
        case connection
    }
    
    var elementType: ElementType
    var logicOperation: LogicOperation
    var inputs: [Input]
    var outputs: [Output]
}
