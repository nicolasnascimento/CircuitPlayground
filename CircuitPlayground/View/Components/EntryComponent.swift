//
//  EntryComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class EntryComponent: GKComponent {
    
    var signal: Signal
    
    var entryNode: EntryNode
    
    // MARK: - Initialization
    init(signal: Signal) {
        
        self.signal = signal
        self.entryNode = EntryNode(signal: signal)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EntryComponent: RenderableComponent {
    var node: SKNode {
        return self.entryNode
    }
}
