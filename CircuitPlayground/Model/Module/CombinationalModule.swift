//
//  CombinationalModule.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct CombinationalModule: Module {
    
    // MARK: - Module
    
    var inputs: [Signal]
    var outputs: [Signal]
    var internalSignals: [Signal]
    var functions: [(inputs: [Signal], logicFunction: LogicFunctionDescriptor)]
    var auxiliarModules: [Module]
    
    // MARK: - Public Properties    
}
