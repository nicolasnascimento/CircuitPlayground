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
    let sourceEntity: RenderableEntity
    let destinationEntity: RenderableEntity
    
    var usedCoordinates: [Coordinate] {
        return self.component(ofType: WireComponent.self)?.path ?? []
    }
    
    // MARK: - Initialization
    init(sourceCoordinate: Coordinate, destinationCoordinate: Coordinate, sourceEntity: RenderableEntity, destinationEntity: RenderableEntity) {
        self.source = sourceCoordinate
        self.destination = destinationCoordinate
        self.sourceEntity = sourceEntity
        self.destinationEntity = destinationEntity
        super.init(at: .zero)
        
        // Wire
        let wireComponent = WireComponent(source: sourceCoordinate, destination: destinationCoordinate)
        self.addComponent(wireComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func connect(avoiding availabilityMatrix: AvailabilityMatrix) {
        self.component(ofType: WireComponent.self)?.connect(avoiding: availabilityMatrix)
    }
}

extension Wire {
    override var debugDescription: String {
        return "Wire - source:\(self.source), destination:\(self.destination)"
        
    }
}
