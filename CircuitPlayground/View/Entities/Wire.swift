//
//  Wire.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class Wire: RenderableEntity {
    
    // MARK: - Public
    let source: Coordinate
    let destination: Coordinate
    
    let usedCoordinates: [Coordinate] = []
    
    
    // MARK: - Initialization
    init(sourceCoordinate: Coordinate, destinationCoordinate: Coordinate, availabilityMatrix: AvailabilityMatrix) {
        self.source = sourceCoordinate
        self.destination = destinationCoordinate
        super.init(at: .zero)
        
        // Wire
        let wireComponent = WireComponent(source: sourceCoordinate, destination: destinationCoordinate, availabilityMatrix: availabilityMatrix)
        self.addComponent(wireComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
