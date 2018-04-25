//
//  SynthesisPerformer.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 24/04/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct SynthesisPerformer {
    
    let version = 1
    let description = "Synthesis Performer"
    
    var expressions: [Expression]
}


extension SynthesisPerformer {

    func extractLogicSpecification() -> LogicSpecification {
        // The extracted VHDL expressions, usually, will be split into 4 different types:
        // Library and use (2 that work as 1), entity and architecture
        //

        var possibleEntity: Entity?
        var possibleArchitecture: Architecture?
        expressions.forEach {
            if let vhdlEntity = $0 as? VHDLEntity {
                possibleEntity = self.extractEntity(from: vhdlEntity)
            } else if let vhdlArchitecture = $0 as? VHDLArchitecture {
                possibleArchitecture = self.extractArchitecture(from: vhdlArchitecture)
            }
        }
        guard let entity = possibleEntity, let architecture = possibleArchitecture else { fatalError("Couldn't extract entity or architecture") }
        return LogicSpecification(version: self.version, description: self.description, entity: entity, architecture: architecture)
    }

    private func extractEntity(from vhdlEntity: VHDLEntity) -> Entity {
        // Extract ports
        let ports: [Port] = vhdlEntity.port.signals.signals.map{

            print("WARNING: Assuming all ports to be single std_logic")
            let numberOfBits = 1
            let signalType: SignalType = .standardLogic
            let direction: Port.Direction
            switch $0.outputDirectionKeyword {
            case .in: direction = .input
            case .out: direction = .output
            default: fatalError("Wrong Keyword on outputdirectionTyoe")
            }

            return Port(name: $0.identifier.name, type: signalType, numberOfBits: numberOfBits, direction: direction)
        }
        return Entity(ports: ports)

    }

    private func extractArchitecture(from vhdlArchitecture: VHDLArchitecture) -> Architecture {
        
        // Store global signals and logic descriptors
        let globalSignals: [GlobalSignal] = self.extractGlobalSignals(from: vhdlArchitecture.signals.signals)
        
        
        let architectureExpressionList = vhdlArchitecture.expression.list
        let logicDescriptors: [LogicDescriptor] = self.extractLogicDescriptors(from: architectureExpressionList)
        
        return Architecture(name: vhdlArchitecture.name.name, globalSignals: globalSignals, logicDescriptors: [])
    }
    
    private func extractGlobalSignals(from signals: [VHDLInternalSignalDeclaration]) -> [GlobalSignal] {
        // Extract global signals
        return signals.map {
            GlobalSignal(name: $0.identifier.name, type: .standardLogic, numberOfBits: 1)
        }
    }
    private func extractLogicDescriptors(from expressionList: [Expression]) -> [LogicDescriptor] {
       
        var descriptors: [LogicDescriptor] = []
        for expression in expressionList {
            
            if let binaryExpression = expression as? VHDLBinaryOperation {
                
                let leftDescriptors = self.extractLogicDescriptors(from: binaryExpression.leftExpression.list)
                
                let expressionOperator = self.extractLogicDescriptor(from: binaryExpression.operator)
                
                let rightDescriptors = self.extractLogicDescriptors(from: binaryExpression.rightExpression.list)
            }
        }
        return descriptors
    }
    
    private func extract
    
    private func extractLogicDescriptor(fromBinaryOperator binaryOperator: Operator, inputs: [Input], outputs: [Output]) -> LogicDescriptor? {
        if let logicOperator = binaryOperator as? Logic {
            switch logicOperator {
            case .and: return LogicDescriptor(elementType: .combinational, logicOperation: .and, inputs: inputs, outputs: outputs)
            case .or: return LogicDescriptor(elementType: .combinational, logicOperation: .or, inputs: inputs, outputs: outputs)
            case .not: return LogicDescriptor(elementType: .combinational, logicOperation: .not, inputs: inputs, outputs: outputs)
            default: return LogicDescriptor(elementType: .combinational, logicOperation: .none, inputs: inputs, outputs: outputs)
            }
        }
        return nil
        
    }
}
