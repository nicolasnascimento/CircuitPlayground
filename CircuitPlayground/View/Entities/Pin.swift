//
//  Pin.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 24/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

protocol Pin {
    // MARK: - Public
    var signal: Signal { get }
    
    init(signal: Signal)
}
