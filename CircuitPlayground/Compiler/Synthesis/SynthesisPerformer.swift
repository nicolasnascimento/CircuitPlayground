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
    
    // MARK: - Initialization
    init(expressions: [Expression]) {
        self.expressions = expressions
    }
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
                
                // Extract all signals before proceeding to architecture extraction
                self.availableSignals = self.extractGlobalSignals(from: vhdlArchitecture.signals.signals, and: possibleEntity?.ports ?? [])
                var architecture = self.extractArchitecture(from: vhdlArchitecture)
                
                // Remove Port related signals from architecture global signals
                architecture.globalSignals = architecture.globalSignals.filter{ signal in
                    return possibleEntity?.ports.index(where: { $0.name == signal.name }) == nil
                }
                
                possibleArchitecture = architecture
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
        let architectureExpressionList = vhdlArchitecture.expression.list
        
        let logicDescriptors: [LogicDescriptor] = self.extractLogicDescriptors(from: architectureExpressionList)
        
        return Architecture(name: vhdlArchitecture.name.name, globalSignals: self.availableSignals, logicDescriptors: logicDescriptors)
    }
    
    private func extractGlobalSignals(from internalSignals: [VHDLInternalSignalDeclaration], and externalSignals: [Port]) -> [GlobalSignal] {
        // Extract global signal
        
        let internalGlobalSignals = internalSignals.map { GlobalSignal(name: $0.identifier.name, type: .standardLogic, numberOfBits: 1) }
        let externalGlobalSignals = externalSignals.map { GlobalSignal(name: $0.name, type: .standardLogic, numberOfBits: 1) }
        
        return internalGlobalSignals + externalGlobalSignals
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
        
        var logicDescriptors: [LogicDescriptor] = []
        
        // If not single sinal was extracted from the right expression, this means we're dealing with a compound expression
        // In this case, we should attach the extracted expressions' output as our input
        if rightInputs.isEmpty {
            let descriptors = self.extractLogicDescriptors(from: binaryExpression.rightExpression.list)
            
            // Create temporary output for logic descriptor to be generated
            let temporarySignal = GlobalSignal(name: "__TEMP__" + "\(self.temporarySignalAmount)", type: .standardLogic, numberOfBits: 1)
            self.availableSignals.append(temporarySignal)
            self.temporarySignalAmount += 1
            
            // Link to logic descriptor output
            let linkedDescriptors = descriptors.map{ LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: $0.outputs + [Output(globalSignal: temporarySignal)]) }
            
            // Add logic descriptor
            logicDescriptors.append(contentsOf: linkedDescriptors)
            
            // Append to inputs of logic descriptor
            rightInputs.append(Input(globalSignal: temporarySignal))
        }
        
        
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
    
                // Create temporary output for logic descriptor to be generated
                let temporarySignal = GlobalSignal(name: "__TEMP__" + "\(self.temporarySignalAmount)", type: .standardLogic, numberOfBits: 1)
                self.availableSignals.append(temporarySignal)
                self.temporarySignalAmount += 1
                
                // Link to logic descriptor output
                let linkedDescriptors = descriptors.map{ LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: $0.outputs + [Output(globalSignal: temporarySignal)]) }
                
                // Add logic descriptor
                logicDescriptors.append(contentsOf: linkedDescriptors)
                
                // Append to inputs of logic descriptor
                leftInputs.append(Input(globalSignal: temporarySignal))
            }
            
            // Add logic descriptor to returnning array
            let newDescriptor = LogicDescriptor(elementType: .combinational, logicOperation: operation, inputs: leftInputs + rightInputs, outputs: [])
            logicDescriptors += [newDescriptor]
        case is Assignment:
            
            // If no logic descriptor is found create a connection
            if logicDescriptors.isEmpty {
                logicDescriptors += [ LogicDescriptor(elementType: .connection, logicOperation: .none, inputs: rightInputs, outputs: []) ]
            }
            
            // In the case of assignment all we need to do is set the left signal as output of the logic descriptor in the right
            guard var leftLogicDescriptor = logicDescriptors.first else { fatalError("Couldn't get a logic descriptor from right expression") }
            leftLogicDescriptor.outputs = leftInputs.map{ Output(name: $0.name) }
            
            logicDescriptors = logicDescriptors.map{
                let outputs = leftInputs.map{ Output(name: $0.name) }
                return LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: outputs)
            }
        case /*let value as*/ is Shift: break
        case /*let value as*/ is Relational: break
        case /*let value as*/ is Miscelaneous: break
        case /*let value as*/ is Math: break
        default: break
        }
        
        return logicDescriptors
    }
}
