//
//  Port.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Port: Codable {
    enum Direction: String, Codable {
        case input
        case output
    }
    var name: String
    var type : SignalType
    var numberOfBits: Int
    var direction : Direction
}
