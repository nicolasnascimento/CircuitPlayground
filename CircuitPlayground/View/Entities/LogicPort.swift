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
    
    override var height: Int { return 4 }
    override var width: Int { return 2 }
    
    var output: Signal {
        return self.component(ofType: LogicPortNodeComponent.self)!.output
    }
    
    init(with operation: LogicDescriptor.LogicOperation, coordinate: Coordinate, inputs: [Signal] = [], output: Signal) {
        super.init(at: coordinate)
        
        let units: Double
        switch operation {
        case .mux: units = 4
        default: units = 2.8
        }
        
        let logicPortNodeComponent = LogicPortNodeComponent(operation: operation, inputs: inputs, output: output, units: units)
        self.addComponent(logicPortNodeComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


