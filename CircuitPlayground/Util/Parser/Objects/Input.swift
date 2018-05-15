//
//  Input.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Input: Codable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Input {
    init(globalSignal: GlobalSignal) {
        self.name = globalSignal.name
    }
}

extension Input {
    static var constantPositive: Input { return Input(name: "VCC") }
    static var constantNegative: Input { return Input(name: "GND") }
}

