//
//  EntryNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class PinNode: SKSpriteNode {

    // MARK: - Public
    
    // The signal this entry node represents
    var signal: Signal
    
    // MARK: - Initialization
    init(signal: Signal) {
        self.signal = signal
        
        super.init(texture: nil, color: SKColor.darkGray, size: GridComponent.maximumIndividualSize)
        
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        // Create Label
        let labelNode = SKLabelNode(text: signal.associatedId)
        self.addChildNode(labelNode)
        
        labelNode.position.x = (self.size.width)*0.5
        labelNode.position.y = (self.size.height - labelNode.frame.size.height)*0.5
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
