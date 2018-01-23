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
            let ports = self.entities(from: module.functions)
            ports.forEach(self.add)
            
            // [Signal] -> [Entry]
            let entries = self.entities(from: module.inputs + module.outputs + module.internalSignals)
            entries.forEach(self.add)
            
            
        default:
            fatalError("Multiple Module Populate function not implemented yet")
        }
    }
    
    private func entities(from functions: [(inputs: [Signal], logicFunction: LogicFunctionDescriptor)]) -> [RenderableEntity] {
        
        return functions.map { function -> RenderableEntity in
            
            let port: LogicPort
            switch function.logicFunction.logicDescriptor {
            case .and:
                print("and")
                port = LogicPort(with: .and, coordinate: .zero)
            case .none:
                print("none")
                port = LogicPort(with: .none, coordinate: .zero)
            case .or:
                print("or")
                port = LogicPort(with: .or, coordinate: .zero)
            case .not:
                print("not")
                port = LogicPort(with: .not, coordinate: .zero)
            }
            
            // Set inputs of the node
            // We'll use this afterwards to perform wiring of ports
            port.inputs = function.inputs
            
            
            return port
        }
    }
    
    private func entities(from signals: [Signal]) -> [RenderableEntity] {
        
        return signals.map{ Entry(at: .zero, signal: $0) }
    }
}
