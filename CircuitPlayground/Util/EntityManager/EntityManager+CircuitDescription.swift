//
//  EntityManager+CircuitDescription.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 25/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

// Adds a function to perform extraction of entities from a circuit descriptoin
extension EntityManager {
    
    /// Extract Entities from a given circuit description
    func populate(with singleModuleCircuitDescription: CircuitDescription) {
        
        switch singleModuleCircuitDescription.modules.count {
        case 1:
            // Get Module
            guard let module = singleModuleCircuitDescription.modules.first else { return }
            
            // [Function] -> [LogicPort]
            // Extract entities and add to list of entities
            let ports = self.ports(from: module.functions)
            ports.forEach(self.add)
            
            // [Signal] -> [EntryPin]
            let entries: [EntryPin] = self.pins(from: module.inputs)
            entries.forEach(self.add)
            
            // [Signal] -> [ExitPin]
            let exits: [ExitPin] = self.pins(from: module.outputs)
            exits.forEach(self.add)
            
            // [Signal] -> [InternalPin]
            let internalPins: [InternalPin] = self.pins(from: module.internalSignals)
            
            // We don't add the interal pin otherwise they will be placed as an input/output pin.
            // Also, there's no need to add them as they will already be placed during port extraction
            internalPins.forEach(self.add)
            
            // Before Adding wires, properly place node
            let availabilityMatrix = self.placeEntriesAndPorts()
            
            // ([Pin], [LogicPort] -> [Wire]
            let pins = (entries as [Pin]) + (internalPins as [Pin]) + (exits as [Pin])
            let pinEntities = (entries as [RenderableEntity & Pin]) + (internalPins as [RenderableEntity & Pin]) + (exits as [RenderableEntity & Pin])
            let wires: [Wire] = self.wires(from: ports, pins: pins, entities: pinEntities, availabilityMatrix: availabilityMatrix)
            wires.forEach { [weak self] in
                self?.add(entity: $0)
                $0.nodeComponent.position = $0.nodeComponent.position
            }
            
            // Remove temporary pins
            internalPins.filter({ $0.signal.associatedId.contains("__TEMP__") }).forEach(self.remove)
            
        default: fatalError("Multiple Module Populate function not implemented yet")
        }
    }
    
    private func placeEntriesAndPorts() -> AvailabilityMatrix {
        
        // A matrix which will be used to control positions which are already taken
        var spots = AvailabilityMatrix(width: Int(GridComponent.maxDimension.x), height: Int(GridComponent.maxDimension.y))

        // Reference coordinates
        let spacing = 1
        let maxX = Int(GridComponent.maxDimension.x) - spacing
        let maxY = Int(GridComponent.maxDimension.y) - spacing
        let minX = spacing
        let minY = spacing

        // Place entries
        let entriesToPlace = self.entities.filter{ $0 is EntryPin } as! [EntryPin]
        var entryPreferedPorts: [RenderableEntity: [RenderableEntity]] = [:]
        var deltaY = (maxY - minY)/entriesToPlace.count
        entriesToPlace.enumerated().forEach { index, entry in

            guard let nodeComponent = entry.component(ofType: NodeComponent.self), let coordinateComponent = entry.component(ofType: GridComponent.self) else  { return }

            let coordinate = Coordinate(x: minX, y: minY + deltaY*index)
            coordinateComponent.set(bottomLeft: coordinate)
            for coordinate in coordinateComponent.coordinates(for: .undefined) {
                spots.set(value: entry, row: coordinate.y, column: coordinate.x)
            }

            nodeComponent.position = coordinateComponent.firstCGPoint ?? .zero

            // Map port to place close
            entryPreferedPorts[entry] = self.entities.filter{
                if let logicPort = $0 as? LogicPort {
                    if logicPort.inputs.contains(where: { $0.associatedId == entry.signal.associatedId }) {
                        return true
                    }
                }
                return false
            } as? [LogicPort]
        }

        // Place ports
        let increment = (maxX - minX)/self.entities.count
        var deltaX = 2*increment
        while !entryPreferedPorts.isEmpty {

            // Create a copy and remove all elements from the general buffer
            // This way, as we positionate ports, we only need to perform iterations if
            // There are ports in the portsToPlace array
            let portsToPlaceCopy = entryPreferedPorts
            entryPreferedPorts.removeAll()

            for item in portsToPlaceCopy {

                var preferedY = item.key.component(ofType: GridComponent.self)!.firstCoordinate!.y
                let preferedX = minX + deltaX
                deltaX += increment

                // Posionate ports which are not already positionated
                for port in item.value where port.component(ofType: GridComponent.self)?.firstCoordinate == .zero {
                    guard let nodeComponent = port.component(ofType: NodeComponent.self), let coordinateComponent = port.component(ofType: GridComponent.self) else  { continue }

                    while let _ = spots.at(row: preferedY, column: preferedX) { preferedY += 4*port.height }

                    let preferedCoordinate = Coordinate(x: preferedX, y: preferedY)
                    coordinateComponent.set(bottomLeft: preferedCoordinate)
                    nodeComponent.position = coordinateComponent.firstCGPoint ?? .zero
                    for coordinate in coordinateComponent.coordinates(for: .undefined) {
                        spots.set(value: port, row: coordinate.y, column: coordinate.x)
                    }

                    let portOutput = port.component(ofType: LogicPortNodeComponent.self)?.output ?? port.component(ofType: PinComponent.self)?.signal

                    // Populate Entry Prefered Port Array
                    entryPreferedPorts[port] = self.entities.filter{
                        if let logicPort = $0 as? LogicPort, let portOutput = portOutput {
                            if logicPort.inputs.contains(where: { $0.associatedId == portOutput.associatedId }){
                                return true
                            }
                        } else if let internalPin = $0 as? InternalPin, let portOutput = portOutput  {
                            if internalPin.signal.associatedId == portOutput.associatedId {
                                return true
                            }
                        }
                        return false
                    } as? [RenderableEntity]
                }
            }
        }


        let exitsToPlace = self.entities.filter({ $0 is ExitPin }) as! [ExitPin]
        deltaY = (maxY - minY)/exitsToPlace.count
        exitsToPlace.enumerated().forEach{ index, exit in

            guard let nodeComponent = exit.component(ofType: NodeComponent.self), let coordinateComponent = exit.component(ofType: GridComponent.self) else  { return }

            let coordinate = Coordinate(x: maxX, y: minY + deltaY*index)
            coordinateComponent.set(bottomLeft: coordinate)
            for coordinate in coordinateComponent.coordinates(for: .undefined) {
                spots.set(value: exit, row: coordinate.y, column: coordinate.x)
            }

            nodeComponent.position = coordinateComponent.firstCGPoint ?? .zero

        }
        
        
//        self.entities.forEach {
//
//            // Get minimum required components
//            guard let nodeComponent = $0.component(ofType: NodeComponent.self), let coordinateComponent = $0.component(ofType: GridComponent.self) else  { return }
//
//            // Iteration Bounds
//            let initialRow = $0 is ExitPin ? spots.height/4 : 1
//            let finalRow = spots.height - 1
//            let initialColumn = $0 is EntryPin ? 1 : $0 is ExitPin ? spots.width - 3 : 3
//            let finalColumn = $0 is EntryPin ? 1 : spots.width - 1
//
//            // Get Spot for item
//            var shouldBreak = false
//            for column in initialColumn...finalColumn {
//                for row in initialRow...finalRow {
//                    let multiplier = $0 is ExitPin ? 1 : 3
//                    let column = column
//                    let row = $0 is LogicPort ? column : row
//
//                    if spots.at(row: row*multiplier, column: column*multiplier) == nil {
//                        coordinateComponent.set(bottomLeft: Coordinate(x: column*multiplier, y: row*multiplier))
//                        for coordinate in coordinateComponent.coordinates(for: .undefined) {
//                            spots.set(value: $0 as? RenderableEntity, row: coordinate.y, column: coordinate.x)
//                        }
//
//                        shouldBreak = true
//                        break
//                    }
//                }
//                if( shouldBreak ) {
//                    break
//                }
//            }
//
//            // Set Correct Position
//            nodeComponent.position = coordinateComponent.firstCGPoint ?? .zero
//        }
        return spots
    }
    
    private func ports(from functions: [(inputs: [Signal], output: Signal, logicFunction: LogicFunctionDescriptor)]) -> [LogicPort] {
        
        let ports = functions.map { function -> LogicPort in
            
            let operation: LogicDescriptor.LogicOperation
            switch function.logicFunction.logicDescriptor {
            case .and: operation =  .and
            case .none: operation = .none
            case .or: operation = .or
            case .not: operation = .not
            case .nand: operation = .nand
            case .nor: operation = .nor
            case .xor: operation = .xor
            case .xnor: operation = .xnor
            case .mux: operation = .mux
            }
            
            let port: LogicPort = LogicPort(with: operation, coordinate: .zero, output: function.output)
            
            // Set inputs of the node
            // We'll use this afterwards to perform wiring of ports
            port.inputs = function.inputs
            
            return port
        }
        
        return ports/*.sorted{
            if let firstCoordinate = $0.component(ofType: GridComponent.self)?.firstCoordinate, let secondCoordinate = $1.component(ofType: GridComponent.self)?.firstCoordinate {
                return firstCoordinate.x > secondCoordinate.x
            }
            return true
        }*/
    }
    
    private func pins<T: Pin>(from signals: [Signal]) -> [T] {
        return signals.map{ T(signal: $0) }
    }
    private func wires(from ports: [LogicPort], pins: [Pin], entities: [RenderableEntity & Pin], availabilityMatrix: AvailabilityMatrix) -> [Wire] {
        
        var wires: [Wire] = []
        
        // We we'll modify this, so use a local instance
        var availabilityMatrix = availabilityMatrix
        
        // Uses entries as starting points first
        for pin in pins.reversed() {
            
            // Check which ports are using the current entry as input
            let portConnections = ports.filter{ port in
                return port.inputs.filter({ signal in
                    return signal.associatedId == pin.signal.associatedId
                }).isEmpty ? false : true
            }
            
            print("pin: \(pin.signal.associatedId), connections: \(portConnections.count)")
            
            // Because there will be multiple input and a single output, We'll use a flag to indicate wheter the port has already been connected to its output
            var outputConnected: Bool = false
            
            // Get input and output entity for each connection
            for portConnection in portConnections {
                
                print("connection: \(portConnections)")
                
                let outputEntity = entities.filter{ $0.signal.associatedId == portConnection.output.associatedId }.first!
                let inputEntities = entities.filter({ entry in portConnection.inputs.index(where: { $0.associatedId == entry.signal.associatedId }) != nil })
                
                // Create 2 Wires ( Pin -> Port & Port -> Output )
                for inputEntity in inputEntities {
                    // Gather 3 connection coordinates
                    let inputCoordinate = self.nextAvailableCoordinate(for: inputEntity, currentWires: wires, usage: .output) /*inputEntity.component(ofType: GridComponent.self)?.firstCoordinate*/ ?? .zero
                    var portCoordinate = self.nextAvailableCoordinate(for: portConnection, currentWires: wires, usage: .input) /*portConnection.component(ofType: GridComponent.self)?.firstCoordinate*/ ?? .zero
                    
                    if !self.wireExists(from: inputEntity, to: portConnection, currentWires: wires) {
                    
                        // Input Pin -> Port
                        let inputWire = Wire(sourceCoordinate: inputCoordinate, destinationCoordinate: portCoordinate, sourceEntity: inputEntity, destinationEntity: portConnection)
                        inputWire.connect(avoiding: availabilityMatrix)
                        wires.append(inputWire)
                       
                        // Update availability Matrix
                        let inputUsedCoordinates: [Coordinate]
                        switch inputEntity {
                        case is EntryPin, is InternalPin: inputUsedCoordinates = Array<Coordinate>(inputWire.usedCoordinates.dropFirst())
                        case is ExitPin: inputUsedCoordinates = Array<Coordinate>(inputWire.usedCoordinates.dropLast())
                        default: inputUsedCoordinates = inputWire.usedCoordinates
                        }
                        inputUsedCoordinates.forEach{
                            availabilityMatrix.set(value: inputWire, row: $0.y, column: $0.x)
                        }
                    }
                    
                    portCoordinate = self.nextAvailableCoordinate(for: portConnection, currentWires: wires, usage: .output) ?? .zero
                    let outputCoordinate = self.nextAvailableCoordinate(for: outputEntity, currentWires: wires, usage: .input) /* outputEntity.component(ofType: GridComponent.self)?.firstCoordinate*/ ?? .zero
                    
                    // Port -> Output Pin
                    if( !outputConnected && !self.wireExists(from: portConnection, to: outputEntity, currentWires: wires) ) {
                        let outputWire = Wire(sourceCoordinate: portCoordinate, destinationCoordinate: outputCoordinate, sourceEntity: portConnection, destinationEntity: outputEntity)
                        outputWire.connect(avoiding: availabilityMatrix)
                        wires.append(outputWire)
                        
                        // Update availability Matrix
                        let outputUsedCoordinates: [Coordinate]
                        switch outputEntity {
                        case is ExitPin, is InternalPin: outputUsedCoordinates = Array<Coordinate>(outputWire.usedCoordinates.dropLast())
                        case is EntryPin: outputUsedCoordinates = Array<Coordinate>(outputWire.usedCoordinates.dropFirst())
                        default: outputUsedCoordinates = outputWire.usedCoordinates
                        }
                        outputUsedCoordinates.forEach{
                            availabilityMatrix.set(value: outputWire, row: $0.y, column: $0.x)
                        }
//                        outputWire.usedCoordinates.forEach{ availabilityMatrix.set(value: outputWire, row: $0.y, column: $0.x) }
                        
                        outputConnected = true
                    }
                }
            }
        }
        return wires
    }
    
    private func nextAvailableCoordinate(for entity: RenderableEntity, currentWires: [Wire], usage: GridComponent.UsageType) -> Coordinate? {
        
        let coordinates = entity.component(ofType: GridComponent.self)?.coordinates(for: usage) ?? []
        if entity is LogicPort {
            for coordinate in coordinates {
                let entitiesInCoordinate = self.entities.filter({ $0.component(ofType: GridComponent.self)?.coordinates(for: usage).index(of: coordinate) != nil })
                
                // If no entities at coordinate, simple return the coordinate
                if entitiesInCoordinate.isEmpty {
                    return coordinate
                } else {
                    // Check available coordinate in entity and return one that is not being used
                    for entityInCoordinate in entitiesInCoordinate {
                        let coordinates = entityInCoordinate.component(ofType: GridComponent.self)?.coordinates(for: usage) ?? []
                        for coordinate in coordinates {
                            if currentWires.filter({ ($0.source == coordinate || $0.destination == coordinate) }).isEmpty {
                                return coordinate
                            }
                        }
                    }
                    
                }
            }
        } else if let coordinate = coordinates.first {
            return coordinate
        }
        return nil
    }
    
    private func wireExists(from source: RenderableEntity, to destination: RenderableEntity, currentWires: [Wire]) -> Bool {
        for wire in currentWires {
            if (wire.sourceEntity == source && wire.destinationEntity == destination) || (wire.sourceEntity == destination && wire.destinationEntity == source) {
                
                return true
            }
            
        }
        return false
        
    }
}

