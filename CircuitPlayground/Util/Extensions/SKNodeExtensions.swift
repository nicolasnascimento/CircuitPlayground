//
//  SKNodeExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 20/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

extension SKNode {

    /// Adds a node correcting zPosition
    func addChildNode(_ node: SKNode) {
        
        // Check zPosition
        if( node.zPosition <= 0.0 ) {
            node.zPosition = CGFloat(self.children.count + 1.0)
        }
        
        // Check if already has a parent
        if let parent = node.parent, parent != self {
            print("\(node) already has a parent, \(parent), will remove from parent")
            node.move(toParent: self)
        } else {
            self.addChild(node)
        }
    }
    
    func center() {
        guard let parentSize = self.parent?.frame.size else {
            print("couldn't center node, no parent frame size could be extracted")
            return
        }
        self.position = CGPoint(x: parentSize.width*0.5, y: parentSize.height*0.5)
    }
}
