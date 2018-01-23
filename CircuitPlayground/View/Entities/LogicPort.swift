//
//  LogicPort.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 21/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class LogicPort: RenderableEntity {
    
    /// The inputs of the logic port
    var inputs: [Signal] {
        set { self.component(ofType: LogicPortNodeComponent.self)?.inputs = inputs }
        get { return self.component(ofType: LogicPortNodeComponent.self)?.inputs ?? [] }
    }
    
    init(with operation: LogicDescriptor.LogicOperation, coordinate: Coordinate, inputs: [Signal] = []) {
        super.init(at: coordinate)
        
        let logicPortNodeComponent = LogicPortNodeComponent(operation: operation, inputs: inputs)
        self.addComponent(logicPortNodeComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
}
