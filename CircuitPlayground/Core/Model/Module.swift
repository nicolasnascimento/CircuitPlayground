//
//  Module.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

protocol Module {
    
    // Entity description
    var inputs: [Signal] { get set }
    var outputs: [Signal] { get set }
    
    // Behaviour description
    var internalSignals: [Signal] { get set }
    var functions: [Signal: LogicFunction] { get set }
    var auxiliarModules: [Module] { get set }
}
