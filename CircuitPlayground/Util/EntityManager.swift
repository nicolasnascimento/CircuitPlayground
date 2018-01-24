//
//  EntityManager.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 07/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

protocol EntityManagerDelegate: class {
    func entityManager(_ entityManager: EntityManager, didAdd entity: GKEntity)
    func entityManager(_ entityManager: EntityManager, didRemove entity: GKEntity)
    func entityManager(_ entityManager: EntityManager, didFailToRemove entity: GKEntity)
}

class EntityManager {
    
    // MARK: - Public Properties
    weak var delegate: EntityManagerDelegate?
    
    // MARK: - Private
    private var entities: [GKEntity]
    
    // MARK: - Initialization
    init() {
        self.entities = []
    }
    
    // MARK: - Public
    func add(entity: GKEntity) {
        // Append entity to list of entities
        self.entities.append(entity)
        
        // Notify the delegate
        self.delegate?.entityManager(self, didAdd: entity)
    }
    func remove(entity: GKEntity) {
        // Assure entity is in array
        guard let index = self.entities.index(of: entity) else {
            self.delegate?.entityManager(self, didFailToRemove: entity)
            return
        }
        // Remove all components from entity before removing it.
        // This allows the components to perform custom behaviour on removal
        let entity = self.entities[index]
        for componentType in entity.components.map({ return type(of: $0) }) {
            entity.removeComponent(ofType: componentType)
        }
        // Remove from list of entities
        self.entities.remove(at: index)
        
        // Notify the delegate
        self.delegate?.entityManager(self, didRemove: entity)
    }
    func removeAllEntities() {
        
        for entity in self.entities {
            self.remove(entity: entity)
        }
    }
}

// Adds a function to perform
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
            internalPins.forEach(self.add)
            
            // Before Adding wires, properly place node
            self.placeEntriesAndPorts()
            
            // ([Pin], [LogicPort] -> [Wire]
            let pins = (entries as [Pin]) + (internalPins as [Pin]) + (exits as [Pin])
            let pinEntities = (entries as [RenderableEntity & Pin]) + (internalPins as [RenderableEntity & Pin]) + (exits as [RenderableEntity & Pin])
            let wires: [Wire] = self.wires(from: ports, pins: pins, entities: pinEntities)
            wires.forEach(self.add)
            
        default:
            fatalError("Multiple Module Populate function not implemented yet")
        }
    }
    
    private func placeEntriesAndPorts() {
        
        // A matrix which will be used to control positions which are already taken
        var spots = AvailabilityMatrix(width: Int(GridComponent.maxDimension.x), height: Int(GridComponent.maxDimension.y))
        
        self.entities.filter({ !($0 is Wire) }).forEach {
            
            // Get minimum required components
            guard let nodeComponent = $0.component(ofType: NodeComponent.self), let coordinateComponent = $0.component(ofType: GridComponent.self) else  { return }
            
            // Iteration Bounds
            let initialRow = 0
            let finalRow = spots.height - 1
            let initialColumn = $0 is EntryPin ?  0 : $0 is ExitPin ? spots.width - 1 : 1
            let finalColumn = $0 is EntryPin ? 0 : spots.width - 1
            
            // Get Spot for item
            var shouldBreak = false
            for column in initialColumn...finalColumn {
                for row in initialRow...finalRow {
                    
                    if( !spots.at(row: row, column: column) ) {
                        coordinateComponent.coordinate = Coordinate(x: column, y: row)
                        spots.set(row: row, column: column)
                        
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
            print("\(coordinateComponent.coordinate)")
        }
        
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
    private func wires(from ports: [LogicPort], pins: [Pin], entities: [RenderableEntity & Pin]) -> [Wire] {
        
        var wires: [Wire] = []
        
        // Uses entries as starting points first
        for pin in pins {
            
            // Check which ports are using the current entry as input
            let portConnections = ports.filter{ port in
                return port.inputs.filter({ signal in
                    return signal.associatedId == pin.signal.associatedId
                }).isEmpty ? false : true
            }
            
            // Get input and output entity for each connection
            for portConnection in portConnections {
                let outputEntity = entities.filter{ $0.signal.associatedId == portConnection.output.associatedId }.first!
                let inputEntities = entities.filter({ entry in portConnection.inputs.index(where: { $0.associatedId == entry.signal.associatedId }) != nil })
                
                // Create Wire
                for inputEntity in inputEntities {
                    let inputCoordinate = inputEntity.component(ofType: GridComponent.self)!.coordinate
                    let outputCoordinate = outputEntity.component(ofType: GridComponent.self)!.coordinate
                    
                    print(inputCoordinate, outputCoordinate)
                    
                    wires.append(Wire(sourceCoordinate: inputCoordinate, destinationCoordinate: outputCoordinate))
                }
            }
        }
        
        return wires
    }
}

extension EntityManager: CustomStringConvertible {
    var description: String {
        var entitiesDescription = ""
        
        for entity in self.entities {
            entitiesDescription += entity.description + "\n"
        }
        
        return "CircuitPlayer.EntityManager - " + entitiesDescription
    }
}
