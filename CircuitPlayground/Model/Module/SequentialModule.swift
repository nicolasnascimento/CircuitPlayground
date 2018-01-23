//
//  SequentialModule.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct SequentialModule: Module {
    
    // MARK: - Module
    
    var inputs: [Signal]
    var outputs: [Signal]
    var internalSignals: [Signal]
    var functions: [(inputs: [Signal], output: Signal, logicFunction: LogicFunctionDescriptor)]
    var auxiliarModules: [Module]
    
    // MARK: - Specific
}

