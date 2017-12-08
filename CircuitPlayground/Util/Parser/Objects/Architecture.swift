//
//  Architecture.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Architecture: Codable {
    var name: String
    var globalSignals: [GlobalSignal]
    var logicDescriptors: [LogicDescriptor]
}
