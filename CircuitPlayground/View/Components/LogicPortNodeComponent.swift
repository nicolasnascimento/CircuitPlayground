//
//  LogicPortNodeComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 21/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class LogicPortNodeComponent: GKComponent {
    
    // MARK: - Public
    var logicPortNode: LogicPortNode
    var inputs: [Signal]
    
    // MARK: - Initialization
    init(operation: LogicDescriptor.LogicOperation, inputs: [Signal] = []) {
        self.inputs = inputs
        self.logicPortNode = LogicPortNode(operation: operation)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogicPortNodeComponent: RenderableComponent {
    var node: SKNode {
        return self.logicPortNode
    }
}
