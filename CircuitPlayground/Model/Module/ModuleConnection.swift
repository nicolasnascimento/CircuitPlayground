//
//  ModuleConnection.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 01/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct ModuleConnection {
    
    typealias ConnectionElement = (input: [Module], output: [Module])
    private(set) var connection: ConnectionElement
    
    init(input: [Module], output: [Module]) {
        self.connection = (input: input, output: output)
    }
}
