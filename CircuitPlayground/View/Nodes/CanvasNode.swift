//
//  CanvasNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 20/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class CanvasNode: SKSpriteNode {
    
    /// The default background color for the Canvas Node
    static let defaultBackgroundColor: SKColor = .lightGray
    
    // MARK: - Initialization
    init(in size: CGSize, color: SKColor = CanvasNode.defaultBackgroundColor) {
        
        // Call super using appropriate parmeters
        super.init(texture: nil, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
