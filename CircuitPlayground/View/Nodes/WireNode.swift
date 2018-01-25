//
//  WireNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

extension NSColor {
    
    static var random: NSColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

final class WireNode: SKShapeNode {

    var source: CGPoint
    var destination: CGPoint
    
    init(points: [CGPoint]) {
        self.source = points.first!
        self.destination = points.last!
        
        super.init()
        
        // Create Path
        let linePath = NSBezierPath()
        
        // Move to Initial Point
        linePath.move(to: self.source)
        
        // Create Connections between points
        for i in 1..<points.count {
         
            linePath.line(to: points[i])
        }
        
        // Set drawing parameters
        self.lineWidth = 3.0
        self.strokeColor = .random
        
        // Draw
        self.path = linePath.cgPath
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
