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
        set { self.component(ofType: LogicPortNodeComponent.self)?.inputs = newValue }
        get { return self.component(ofType: LogicPortNodeComponent.self)?.inputs ?? [] }
    }
    
    var output: Signal {
        return self.component(ofType: LogicPortNodeComponent.self)!.output
    }
    
    init(with operation: LogicDescriptor.LogicOperation, coordinate: Coordinate, inputs: [Signal] = [], output: Signal) {
        super.init(at: coordinate)
        
        let logicPortNodeComponent = LogicPortNodeComponent(operation: operation, inputs: inputs, output: output)
        self.addComponent(logicPortNodeComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


