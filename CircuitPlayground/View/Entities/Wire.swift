//
//  Wire.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class Wire: RenderableEntity {
    
    
    
    init(at coordinate: Coordinate, inputs: [LogicPort], outputs: [LogicPort]) {
        super.init(at: coordinate)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
