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
}

extension Input {
    init(globalSignal: GlobalSignal) {
        self.name = globalSignal.name
    }
}
