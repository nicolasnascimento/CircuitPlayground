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
            switch $0 {
            case let value as VHDLBinaryOperation:
                let logicDescriptors = self.extractLogicDescriptor(from: value)
                descriptors.append(contentsOf: logicDescriptors)
            case let value as VHDLWhenElse:
                let logicDescriptos = self.extractLogicDescriptors(from: value)
                descriptors.append(contentsOf: logicDescriptos)
            case let value as VHDLProcess:
                let logicDescriptors = self.extractLogicDescriptors(from: value)
                descriptors.append(contentsOf: logicDescriptors)
            default:
                print("Couldn't extract logic descriptor for \(type(of:$0))")
            }
        }
        return descriptors
    }
    
    private mutating func extractLogicDescriptors(from vhdlProcess: VHDLProcess) -> [LogicDescriptor] {
        
        switch vhdlProcess.expression {
        case let value as VHDLIf: return self.extractLogicDescriptors(from: value)
        case let value as VHDLIfElse: return self.extractLogicDescriptors(from: value)
        default:
            print("WARNING: Couldn't extract any expression from sequential expression: \(vhdlProcess.expression)")
            return []
        }
    }
    
    // An If expression, in general, is used to describe multiplexed expressions
    // Though there's always the chance of 'Infering a Latch'
    private mutating func extractLogicDescriptors(from vhdlIf: VHDLIf) -> [LogicDescriptor] {
        
        let descriptors = self.extractLogicDescriptors(from: vhdlIf.onTrueExpression.list)
        
        // Link to logic descriptor output
        let (linkedDescriptors, _) = self.link(from: descriptors)
        

//        linked
        
        return linkedDescriptors
    }
    
    // An If else expression, in general, is used to describe multiplexed expressions
    // Thought
    private func extractLogicDescriptors(from vhdlIfElse: VHDLIfElse) -> [LogicDescriptor] {
        
    }
    
    private func extractInputFrom(expression: Expression) -> [Input] {
        // Attemp extracting identifier
        if let identifier = expression as? VHDLIdentifier {
            if let inputSignal = self.availableSignals.compactMap({ $0.name == identifier.name ? Input(name: $0.name) : nil }).first {
                return [inputSignal]
            }
        
        // Attemp extracting a constant value
        } else if let constant = expression as? VHDLConstant {
            
            switch constant.rawType {
            case .bit(let value):
                if value {
                    return [Input.constantPositive]
                } else {
                    return [Input.constantNegative]
                }
            default: break
            }
        }
        return []
    }
    
    private mutating func extractLogicDescriptor(from binaryExpression: VHDLBinaryOperation) -> [LogicDescriptor] {
        // The inputs and outputs
        var leftInputs: [Input] = self.extractInputFrom(expression: binaryExpression.leftExpression)
        var rightInputs: [Input] = self.extractInputFrom(expression: binaryExpression.rightExpression)
        
        // Add VCC or GND if required to global list of signals
        let shouldAddVCCToGlobalPins = (!leftInputs.filter({ $0.name == Input.constantPositive.name }).isEmpty || !rightInputs.filter({ $0.name == Input.constantPositive.name }).isEmpty) && self.availableSignals.filter({ $0.name == Input.constantPositive.name }).isEmpty
        let shouldAddGNDToGlobalPins = (!leftInputs.filter({ $0.name == Input.constantNegative.name }).isEmpty || !rightInputs.filter({ $0.name == Input.constantNegative.name }).isEmpty) && self.availableSignals.filter({ $0.name == Input.constantNegative.name }).isEmpty
        if shouldAddVCCToGlobalPins {
            self.availableSignals.append(GlobalSignal(name: Input.constantPositive.name, type: .standardLogic, numberOfBits: 1))
        }
        if shouldAddGNDToGlobalPins {
            self.availableSignals.append(GlobalSignal(name: Input.constantNegative.name, type: .standardLogic, numberOfBits: 1))
        }
        
        var logicDescriptors: [LogicDescriptor] = []
        
        // If not single sinal was extracted from the right expression, this means we're dealing with a compound expression
        // In this case, we should attach the extracted expressions' output as our input
        if rightInputs.isEmpty {
            let descriptors = self.extractLogicDescriptors(from: binaryExpression.rightExpression.list)
            
            // Link to logic descriptor output
            let (linkedDescriptors, temporarySignal) = self.link(from: descriptors)
            
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
            case .nand: operation = .nand
            case .nor: operation = .nor
            case .xor: operation = .xor
            case .xnor: operation = .xnor
            }
            
            // If not single sinal was extracted this means we're dealing with a compound expression
            // In this case, we should attach the extracted expressions' output as our input
            if leftInputs.isEmpty {
                let descriptors = self.extractLogicDescriptors(from: binaryExpression.leftExpression.list)
    
                // Link to logic descriptor output
                let (linkedDescriptors, temporarySignal) = self.link(from: descriptors)
                
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
                logicDescriptors += [LogicDescriptor(elementType: .connection, logicOperation: .none, inputs: rightInputs, outputs: [])]
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
    
    private mutating func link(from descriptors: [LogicDescriptor]) -> (logicDescriptors: [LogicDescriptor], temporarySignal: GlobalSignal) {
        
        // Create temporary output for logic descriptor to be generated
        let temporarySignal = GlobalSignal(name: "__TEMP__" + "\(self.temporarySignalAmount)", type: .standardLogic, numberOfBits: 1)
        self.availableSignals.append(temporarySignal)
        self.temporarySignalAmount += 1
        
        // Link to logic descriptor output
        let linkedDescriptors = descriptors.map{ LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs, outputs: $0.outputs + [Output(globalSignal: temporarySignal)]) }
        return (linkedDescriptors, temporarySignal)
    }
    
    private mutating func extractLogicDescriptors(from whenElseExpression: VHDLWhenElse) -> [LogicDescriptor] {
        // A multiplexer is different from a standard logic port, as it requires the inputs and selection bit
        // We'll extract these items separately
        
        // Extract descriptors from partial expressions
        var descriptors = self.extractInputs(from: whenElseExpression.partialWhelElseExpressions)
        
        // Extract default expression
        if let defaultExpression = whenElseExpression.defaultValue {
            if let constant = defaultExpression as? VHDLIdentifier {
                
                descriptors = descriptors.map{ LogicDescriptor(elementType: $0.elementType, logicOperation: $0.logicOperation, inputs: $0.inputs + [Input(name: constant.name)], outputs: $0.outputs) }
            }
            
//            let defaultLogicDescriptors = self.extractLogicDescriptors(from: defaultExpression.list)
//            let (linkedDescriptors, _) = self.link(from: defaultLogicDescriptors)
            
//            descriptors.append(contentsOf: linkedDescriptors)
            
        }
        
        return descriptors
    }
    
    private mutating func extractInputs(from partialWhenElseExpressions: [VHDLPartialWhenElse]) -> [LogicDescriptor] {
        
        // First extract the selection bits
        let selectionBits = partialWhenElseExpressions
            .compactMap { (partialExpression: VHDLPartialWhenElse) -> Input? in
                if let simpleComparision = partialExpression.booleanExpression as? VHDLBinaryOperation {
                    if let operation = simpleComparision.operator as? Relational, operation == .equal,
                        let leftOperator = simpleComparision.leftExpression as? VHDLIdentifier,
                        let _ = simpleComparision.rightExpression as? VHDLConstant {
                            return self.extractInputFrom(expression: leftOperator).first
                    }
                } else {
                    print("WARNING: When else expression has complex expression")
                }
                return nil
            }
            .removingDuplicates()
            .map{ (input: Input) -> Input in
                var input = input
                input.isSelectionBit = true
                return input
            }
        // Next attemp to extrac inputs in 2 steps
        
        // First: Simple inputs
        var inputs: [Input] = []
        partialWhenElseExpressions.forEach{
            inputs.append(contentsOf: self.extractInputFrom(expression: $0.leftExpression))
        }
        
        // Second: Compound inputs
        var logicDescriptors: [LogicDescriptor] = []
        let options: [Input] = partialWhenElseExpressions.compactMap{ (partialExpression: VHDLPartialWhenElse) -> Input? in
            let descriptors = self.extractLogicDescriptors(from: partialExpression.leftExpression.list)
            
            if descriptors.count != 0{
            
                // Link to logic descriptor output
                let (linkedDescriptors, temporarySignal) = self.link(from: descriptors)
                
                // Add logic descriptor
                logicDescriptors.append(contentsOf: linkedDescriptors)
                
                // Append to inputs of logic descriptor
                return Input(globalSignal: temporarySignal)
            }
            return nil
        }

        // Append new logic descriptor
        logicDescriptors.append(LogicDescriptor(elementType: .connection, logicOperation: .mux, inputs: inputs + selectionBits + options, outputs: []))
        
        return logicDescriptors
        
    }
}
