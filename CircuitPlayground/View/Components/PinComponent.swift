//
//  EntryComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class PinComponent: GKComponent {
    
    var signal: Signal
    var pinNode: PinNode
    var type: PinType
    
    enum PinType {
        case entry
        case exit
        case `internal`
    }
    
    // MARK: - Initialization
    init(signal: Signal, type: PinType) {
        
        self.signal = signal
        self.type = type
        
        let imageName: String
        switch type {
        default: imageName = Environment.Images.pinImageName
        }
        
        self.pinNode = PinNode(imageNamed: imageName, associatedId: signal.associatedId)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PinComponent: RenderableComponent {
    var node: SKNode {
        return self.pinNode
    }
}
