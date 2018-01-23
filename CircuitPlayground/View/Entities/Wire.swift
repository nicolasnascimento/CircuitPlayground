//
//  Wire.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class Wire: RenderableEntity {
    
    var source: Coordinate
    var destination: Coordinate
    
    // MARK: - Initialization
    init(sourceCoordinate: Coordinate, destinationCoordinate: Coordinate) {
        self.source = sourceCoordinate
        self.destination = destinationCoordinate
        super.init(at: .zero)
        
        self.source = sourceCoordinate
        self.destination = destinationCoordinate
        
        // Wire
        let wireComponent = WireComponent(source: sourceCoordinate, destination: destinationCoordinate)
        self.addComponent(wireComponent)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Wire {
    override var description: String {
        return "Wire - source(\(self.source) destination(\(self.destination)"
    }
}
