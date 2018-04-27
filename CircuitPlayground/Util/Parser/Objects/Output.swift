//
//  Output.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Output: Codable {
    var name: String
}

extension Output {
    init(globalSignal: GlobalSignal) {
        self.name = globalSignal.name
    }
}
