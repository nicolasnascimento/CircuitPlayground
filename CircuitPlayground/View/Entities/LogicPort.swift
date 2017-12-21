//
//  LogicPort.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 21/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class LogicPort: RenderableEntity {
    
    init(with operation: LogicDescriptor.LogicOperation) {
        super.init()
        
        let logicPortNodeComponent = LogicPortNodeComponent(operation: operation)
        self.addComponent(logicPortNodeComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public
}
