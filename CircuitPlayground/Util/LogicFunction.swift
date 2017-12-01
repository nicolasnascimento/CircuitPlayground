//
//  LogicFunction.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

// Simple definition of a logic function
typealias LogicFunction = ((_ inputs: [Signal]) -> StandardLogicValue)
