//
//  SequentialModule.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

class SequentialModule {

    // MARK: - Module
    
    // Entity description
    var inputs: [Signal] = []
    var outputs: [Signal] = []
    
    // Behaviour description
    var internalSignals: [Signal] = []
    var functions: [Signal: LogicFunction] = [:]
    var auxiliarModules: [Module] = []
    
    // MARK: - Specific
    
}

extension SequentialModule: Module {
    
}
