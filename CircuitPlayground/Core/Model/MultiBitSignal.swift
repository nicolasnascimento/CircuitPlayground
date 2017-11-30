//
//  MultiBitSignal.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct MultiBitSignal: Signal {
    var associatedId: String
    
    var numberOfBits: Int
    var bits: [StandardLogicValue] = []
    
    init(associatedId: String, numberOfBits: Int, bits: [StandardLogicValue]) {
        self.associatedId = associatedId
        self.numberOfBits = numberOfBits
        self.bits = bits
    }

}
