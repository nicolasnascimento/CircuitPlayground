//
//  SynthesisPerformer.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 24/04/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct SynthesisPerformer {
    // Version and Description
    let version = 1
    let description = "Synthesis Performer"
    
    // Expressions to be used for synthesis performing
    var expressions: [Expression]
    
    // The list of available inputs and outputs
    // This will be used
    private var availableSignals: [GlobalSignal] = []
    private var temporarySignalAmount: Int = 0
}


extension SynthesisPerformer {

    mutating func extractLogicSpecification() -> LogicSpecification {
        // The extracted VHDL expressions, usually, will be split into 4 different types:
        // Library and use (2 that work as 1), entity and architecture

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

    private mutating func extractArchitecture(from vhdlArchitecture: VHDLArchitecture) -> Architecture {
        
        // Store global signals and logic descriptors
        self.availableSignals = self.extractGlobalSignals(from: vhdlArchitecture.signals.signals)
        
        let architectureExpressionList = vhdlArchitecture.expression.list
        
        let logicDescriptors: [LogicDescriptor] = self.extractLogicDescriptors(from: architectureExpressionList)
        
        return Architecture(name: vhdlArchitecture.name.name, globalSignals: self.availableSignals, logicDescriptors: logicDescriptors)
    }
    
    private func extractGlobalSignals(from signals: [VHDLInternalSignalDeclaration]) -> [GlobalSignal] {
        // Extract global signals
        return signals.map {
            GlobalSignal(name: $0.identifier.name, type: .standardLogic, numberOfBits: 1)
        }
    }
    private mutating func extractLogicDescriptors(from expressionList: [Expression]) -> [LogicDescriptor] {
       
        var descriptors: [LogicDescriptor] = []
        expressionList.forEach {
            // Check for binary expressions
            if let binaryExpression = $0 as? VHDLBinaryOperation {
                descriptors.append(contentsOf: self.extractLogicDescriptor(from: binaryExpression))
            }
        }
        return descriptors
    }
    private func extractInputFrom(expression: Expression) -> [Input] {
        // Extract left logic descriptor
        if let identifier = expression as? VHDLIdentifier {
            if let inputSignal = self.availableSignals.compactMap({ $0.name == identifier.name ? Input(name: $0.name) : nil }).first {
                return [inputSignal]
            }
        }
        return []
    }
    
    private mutating func extractLogicDescriptor(from binaryExpression: VHDLBinaryOperation) -> [LogicDescriptor] {
        // The inputs and outputs
        var leftInputs: [Input] = self.extractInputFrom(expression: binaryExpression.leftExpression)
        var rightInputs: [Input] = self.extractInputFrom(expression: binaryExpression.rightExpression)
        
        // If the signal is composed, extract logic descriptor from it then
        switch binaryExpression.operator {
        case let value as Logic:
            var operation: LogicDescriptor.LogicOperation = .none
            switch value {
            case .and: operation = .and
            case .or: operation = .or
            case .not: operation = .not
            default: operation = .none
            }
            
            // If not single sinal was extracted this means we're dealing with a compound expression
            // In this case, we should attach the extracted expressions' output as our input
            if leftInputs.isEmpty {
                let descriptors = self.extractLogicDescriptors(from: binaryExpression.leftExpression.list)
                let inputs = descriptors.reduce([], { $0 + $1.inputs })
                leftInputs.append(contentsOf: inputs)
            }
            
            // If not single sinal was extracted this means we're dealing with a compound expression
            // In this case, we should attach the extracted expressions' output as our input
            if rightInputs.isEmpty {
                let descriptors = self.extractLogicDescriptors(from: binaryExpression.rightExpression.list)
                
                // Create temporary output for logic descriptor to be generated
                let temporarySignal = GlobalSignal(name: "__TEMP__" + "\(self.temporarySignalAmount)", type: .standardLogic, numberOfBits: 1)
                self.availableSignals.append(temporarySignal)
                self.temporarySignalAmount += 1
                
                // Link to logic descriptor output
                let linkedDescriptors = descriptors.map{ LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: $0.outputs + [Output(name: temporarySignal.name)]) }
                
                // Append to inputs of logic descriptor
//                rightInputs.append(contentsOf: linkedDescriptors)
            }
            
            return [LogicDescriptor(elementType: .combinational, logicOperation: operation, inputs: leftInputs + rightInputs, outputs: [])]
        case let value as Assignment:
            // By extracting the right expression, we're going to get back a
            if rightInputs.isEmpty {
                let descriptors = self.extractLogicDescriptors(from: binaryExpression.rightExpression.list)
                let inputs = descriptors.reduce([], { $0 + $1.inputs })
                rightInputs.append(contentsOf: inputs)
            }
            
            return []//[LogicDescriptor(elementType: .combinational, logicOperation: operation, inputs: [], outputs: [])]
        case /*let value as*/ is Shift: return []
        case /*let value as*/ is Relational: return []
        case /*let value as*/ is Miscelaneous: return []
        case /*let value as*/ is Math: return []
        default: return []
        }
    }
}
