//
//  WireNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

final class WireNode: SKShapeNode {

    // A boolean that indicates wheter or not we should add some noise when performing wiring of nodes
    private let hasNoise = false
    
    // The source and destination points to create the WireNode from
    var source: CGPoint
    var destination: CGPoint
    
    init(points: [CGPoint]) {
        self.source = points.first ?? .zero
        self.destination = points.last ?? .zero
        
        super.init()
        
        // Create Path
        let linePath = NSBezierPath()
        
        // Move to Initial Point
        linePath.move(to: self.source)
        
        // Create Connections between points
        if( !points.isEmpty ) {
            for i in 1..<points.count {
                
                let xNoise = i + 1 == points.count ? CGFloat(0) : self.hasNoise ?  CGFloat(drand48() * 30) : 0
                let yNoise = i + 1 == points.count ? CGFloat(0) : self.hasNoise ?  CGFloat(drand48() * 30) : 0
                let point = CGPoint(x: points[i].x + xNoise, y: points[i].y + yNoise)
             
                linePath.line(to: point)
            }
        }
        
        // Set drawing parameters
        self.lineWidth = 2.0
        self.strokeColor = .random
        
        // Draw
        self.path = linePath.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
