//
//  Signal.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

enum StandardLogicValue: Int {
    case positive
    case negative
    case unknown
}

protocol Signal {
    var numberOfBits: Int { get }
    var associatedId: String { get set }
    var bits: [StandardLogicValue] { get set }
}

