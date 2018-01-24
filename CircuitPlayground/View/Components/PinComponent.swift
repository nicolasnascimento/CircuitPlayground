//
//  EntryComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class PinComponent: GKComponent {
    
    var signal: Signal
    
    var entryNode: PinNode
    
    // MARK: - Initialization
    init(signal: Signal) {
        
        self.signal = signal
        self.entryNode = PinNode(signal: signal)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PinComponent: RenderableComponent {
    var node: SKNode {
        return self.entryNode
    }
}
