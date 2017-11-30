//
//  SingleBitSignal.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct SingleBitSignal: Signal {
    let numberOfBits: Int = 1
    
    var associatedId: String
    var bits: [StandardLogicValue] = []

    
    init(associatedId: String, value: StandardLogicValue) {
        self.associatedId = associatedId
        self.bits = [value]
    }
}
