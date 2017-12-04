//
//  LogicSpecification.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 04/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct LogicSpecification: Codable {
    var version: Int
    var description: String
    var entity: Entity
    var architecture: Architecture
    
}
