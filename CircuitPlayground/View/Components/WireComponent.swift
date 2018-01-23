//
//  WireComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class WireComponent: GKComponent {
    
    var wireNode: WireNode
    
    init(source: Coordinate, destination: Coordinate) {
        self.wireNode = WireNode(source: GridComponent.position(for: source), destination: GridComponent.position(for: destination))
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WireComponent: RenderableComponent {
    var node: SKNode {
        return self.wireNode
    }
}
