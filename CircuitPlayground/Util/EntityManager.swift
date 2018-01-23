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
            
            // [Signal] -> [Entry]
            let entries = self.entries(from: module.inputs + module.outputs + module.internalSignals)
            entries.forEach(self.add)
            
            // ([Entry], [LogicPort] -> [Wire]
            let wires = self.wires(from: ports, entries: entries)
            wires.forEach(self.add)
            
        default:
            fatalError("Multiple Module Populate function not implemented yet")
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
    
    private func entries(from signals: [Signal]) -> [Entry] {
        return signals.map{ Entry(at: .zero, signal: $0) }
    }
    private func wires(from ports: [LogicPort], entries: [Entry]) -> [Wire] {
        
        var wires: [Wire] = []
        
        // Uses entries as starting points first
        for entry in entries {
            
            // Check which ports are using the current entry as input
            let portConnections = ports.filter{ port in
                return port.inputs.filter({ signal in
                    return signal.associatedId == entry.signal.associatedId
                }).isEmpty ? false : true
            }
            
            // Get input and output entity for each connection
            for portConnection in portConnections {
                let outputEntity = entries.filter{ $0.signal.associatedId == portConnection.output.associatedId }.first!
                let inputEntities = entries.filter({ entry in portConnection.inputs.index(where: { $0.associatedId == entry.signal.associatedId }) != nil })
                
                // Create Wire
                for inputEntity in inputEntities {
                    let inputCoordinate = inputEntity.component(ofType: GridComponent.self)!.coordinate
                    let outputCoordinate = outputEntity.component(ofType: GridComponent.self)!.coordinate
                    
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
