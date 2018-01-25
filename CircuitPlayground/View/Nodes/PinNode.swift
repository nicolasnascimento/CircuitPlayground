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
        
        // Create Label
        let labelNode = LabelNode(text: associatedId)
        self.addChildNode(labelNode)
        
        labelNode.position.x = (self.size.width)*0.5
        labelNode.position.y = (self.size.height*2.5 - labelNode.frame.size.height)*0.5
        labelNode.zPosition += 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
