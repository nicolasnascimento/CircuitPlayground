//
//  GlobalSignal.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

enum SignalType: String, Codable {
    case standardLogic
    case standardLogicVector
}

struct GlobalSignal: Codable {
    var name: String
    var type: SignalType
    var numberOfBits: Int
}
