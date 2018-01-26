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
//            internalPins.forEach(self.add)
            
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
            
        default:
            fatalError("Multiple Module Populate function not implemented yet")
        }
    }
    
    private func placeEntriesAndPorts() -> AvailabilityMatrix {
        
        // A matrix which will be used to control positions which are already taken
        var spots = AvailabilityMatrix(width: Int(GridComponent.maxDimension.x), height: Int(GridComponent.maxDimension.y))
        
        self.entities.forEach {
            
            // Get minimum required components
            guard let nodeComponent = $0.component(ofType: NodeComponent.self), let coordinateComponent = $0.component(ofType: GridComponent.self) else  { return }
            
            // Iteration Bounds
            let initialRow = $0 is ExitPin ? spots.height/2 : 0
            let finalRow = spots.height - 1
            let initialColumn = $0 is EntryPin ?  0 : $0 is ExitPin ? spots.width - 1 : 1
            let finalColumn = $0 is EntryPin ? 0 : spots.width - 1
            
            // Get Spot for item
            var shouldBreak = false
            for column in initialColumn...finalColumn {
                for row in initialRow...finalRow {
                    let multiplier = $0 is ExitPin ? 1 : 2
                    if( spots.at(row: row*multiplier, column: column*multiplier) == nil ) {
                        coordinateComponent.coordinate = Coordinate(x: column*multiplier, y: row*multiplier)
                        spots.set(value: $0 as? RenderableEntity,row: row*multiplier, column: column*multiplier)
                        
                        shouldBreak = true
                        break
                    }
                }
                if( shouldBreak ) {
                    break
                }
            }
            
            // Set Correct Position
            nodeComponent.position = coordinateComponent.cgPoint
        }
        
        
        return spots
    }
    
    private func ports(from functions: [(inputs: [Signal], output: Signal, logicFunction: LogicFunctionDescriptor)]) -> [LogicPort] {
        
        return functions.map { function -> LogicPort in
            
            let port: LogicPort
            switch function.logicFunction.logicDescriptor {
            case .and:
                print("and")
                port = LogicPort(with: .and, coordinate: .zero, output: function.output)
            case .none:
                print("none")
                port = LogicPort(with: .none, coordinate: .zero, output: function.output)
            case .or:
                print("or")
                port = LogicPort(with: .or, coordinate: .zero, output: function.output)
            case .not:
                print("not")
                port = LogicPort(with: .not, coordinate: .zero, output: function.output)
            }
            
            // Set inputs of the node
            // We'll use this afterwards to perform wiring of ports
            port.inputs = function.inputs
            
            
            return port
        }
    }
    
    private func pins<T: Pin>(from signals: [Signal]) -> [T] {
        return signals.map{ T(signal: $0) }
    }
    private func wires(from ports: [LogicPort], pins: [Pin], entities: [RenderableEntity & Pin], availabilityMatrix: AvailabilityMatrix) -> [Wire] {
        
        var wires: [Wire] = []
        
        // We we'll modify this, so use a local instance
        var availabilityMatrix = availabilityMatrix
        
        // Uses entries as starting points first
        for pin in pins {
            
            // Check which ports are using the current entry as input
            let portConnections = ports.filter{ port in
                return port.inputs.filter({ signal in
                    return signal.associatedId == pin.signal.associatedId
                }).isEmpty ? false : true
            }
            
            // Because there will be multiple input and a single output, We'll use a flag to indicate wheter the port has already been connected to its output
            var outputConnected: Bool = false
            
            // Get input and output entity for each connection
            for portConnection in portConnections {
                let outputEntity = entities.filter{ $0.signal.associatedId == portConnection.output.associatedId }.first!
                let inputEntities = entities.filter({ entry in portConnection.inputs.index(where: { $0.associatedId == entry.signal.associatedId }) != nil })
                
                
                // Create 2 Wires ( Pin -> Port & Port -> Output )
                for inputEntity in inputEntities {
                    // Gather 3 connection coordinates
                    let inputCoordinate = inputEntity.component(ofType: GridComponent.self)!.coordinate
                    let outputCoordinate = outputEntity.component(ofType: GridComponent.self)!.coordinate
                    let portCoordinate = portConnection.component(ofType: GridComponent.self)!.coordinate
                    
                    print(inputCoordinate, portCoordinate, outputCoordinate)

                    if( !(inputEntity is InternalPin) ) {
                    
                        // Input Pin -> Port
                        let inputWire = Wire(sourceCoordinate: inputCoordinate, destinationCoordinate: portCoordinate)
                        inputWire.connect(avoiding: availabilityMatrix)
                        wires.append(inputWire)
                       
                        // Update availability Matrix
                        inputWire.usedCoordinates.forEach{ availabilityMatrix.set(value: inputWire,row: $0.y, column: $0.x) }
                    }
                    
                    // Port -> Output Pin
                    if( !outputConnected ) {
                        let outputWire = Wire(sourceCoordinate: portCoordinate, destinationCoordinate: outputCoordinate)
                        outputWire.connect(avoiding: availabilityMatrix) 
                        wires.append(outputWire)
                        
                        // Update availability Matrix
                        outputWire.usedCoordinates.forEach{ availabilityMatrix.set(value: outputWire, row: $0.y, column: $0.x) }
                        
                        outputConnected = true
                    }
                }
            }
        }
        
        return wires
    }
}

