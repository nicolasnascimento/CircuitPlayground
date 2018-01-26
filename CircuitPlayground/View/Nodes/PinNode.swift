//
//  EntryNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

final class PinNode: SKSpriteNode {
    
    // MARK: - Initialization
    init(imageNamed: String, associatedId: String) {
        
        let texture = SKTexture(imageNamed: imageNamed)
        let textureSize = texture.size()
        super.init(texture: texture, color: SKColor.darkGray, size: textureSize)
        self.resize(toFitHeight: GridComponent.maximumIndividualSize.height)
        
        // Set anchor point of node
        self.anchorPoint = CGPoint(x: 0, y: 0)
        
        self.addLabel(for: associatedId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
