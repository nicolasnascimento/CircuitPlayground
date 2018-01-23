//
//  EntryNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class EntryNode: SKSpriteNode {

    // MARK: - Public
    
    // The signal this entry node represents
    var signal: Signal
    
    // MARK: - Initialization
    init(signal: Signal) {
        self.signal = signal
        
        super.init(texture: nil, color: SKColor.lightGray, size: GridComponent.maximumIndividualSize)
        
        // Create Label
        let labelNode = SKLabelNode(text: signal.associatedId)
        self.addChildNode(labelNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
