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
    case unknown = "X"
}

// Describes the necessary properties for a Signal
protocol Signal {
    var numberOfBits: Int { get }
    var associatedId: String { get set }
    var bits: [StandardLogicValue] { get set }
}

