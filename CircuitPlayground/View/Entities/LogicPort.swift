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
    
    override var height: Int {
        switch self.operation {
        case .mux: return 4
        default: return 3
        }
    }
    override var width: Int {
        switch self.operation {
        default: return 2
        }
    }
    
    var output: Signal {
        return self.component(ofType: LogicPortNodeComponent.self)!.output
    }
    
    private let operation: LogicDescriptor.LogicOperation
    
    init(with operation: LogicDescriptor.LogicOperation, coordinate: Coordinate, inputs: [Signal] = [], output: Signal) {
        self.operation = operation
        super.init(at: coordinate)
        
        let logicPortNodeComponent = LogicPortNodeComponent(operation: operation, inputs: inputs, output: output, height: self.height, width: self.width)
        self.addComponent(logicPortNodeComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


