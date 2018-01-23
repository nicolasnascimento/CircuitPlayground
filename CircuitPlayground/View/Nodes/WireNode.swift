//
//  WireNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class WireNode: SKShapeNode {

    var source: CGPoint
    var destination: CGPoint
    
    init(source: CGPoint, destination: CGPoint) {
        self.source = source
        self.destination = destination
        
        super.init()
        
        // Create Path
        let linePath = NSBezierPath()
        linePath.move(to: source)
        linePath.line(to: destination)
        
        // Set drawing parameters
        self.lineWidth = 1.0
        self.strokeColor = .lightGray
        self.path = linePath.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
