//
//  CircuitDescription.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct CircuitDescription {
    var modules: [Module]
    var connections: [ModuleConnection]
}


extension CircuitDescription {
    init(specification: LogicSpecification) {
        // Perform Initialization with empty description
        self.init(modules: [], connections: [])
        
        // Extract Main Module from Specification
        let entityModule = self.extractModule(from: specification)
        self.modules.append(entityModule)
    }
    
    fileprivate func extractModule(from specification: LogicSpecification) -> Module {
        var module = CombinationalModule(inputs: [], outputs: [], internalSignals: [], functions: [:], auxiliarModules: [])
        
        // Extract Input and Output Ports
        let portTranslation = self.extractInputsAndOutputs(from: specification.entity.ports)
        module.inputs = portTranslation.inputs
        module.outputs = portTranslation.outputs
        
        // Extract Internal Signals
        module.internalSignals = self.extractInternalSignals(from: specification.architecture.globalSignals)
    
        // Extract Functions
        module.functions = self.extractLogicFunctions(from: specification.architecture.logicDescriptors, availableInputSignals: module.inputs + module.internalSignals, availableOutputSignals: module.outputs + module.internalSignals)
        
        return module
        
    }
    fileprivate func extractInputsAndOutputs(from ports: [Port]) -> (inputs: [Signal], outputs: [Signal]) {
        var inputs: [Signal] = []
        var outputs: [Signal] = []
        ports.forEach {
            switch $0.direction {
            case .input:
                switch $0.type {
                case .standardLogic:
                    let signal = SingleBitSignal(associatedId: $0.name, value: .negative)
                    inputs.append(signal)
                case .standardLogicVector:
                    let bits = [StandardLogicValue](repeating: .negative, count: $0.numberOfBits)
                    let signal = MultiBitSignal(associatedId: $0.name, numberOfBits: $0.numberOfBits, bits: bits)
                    inputs.append(signal)
                }
            case .output:
                switch $0.type {
                case .standardLogic:
                    let signal = SingleBitSignal(associatedId: $0.name, value: .negative)
                    outputs.append(signal)
                case .standardLogicVector:
                    let bits = [StandardLogicValue].init(repeating: .negative, count: $0.numberOfBits)
                    let signal = MultiBitSignal(associatedId: $0.name, numberOfBits: $0.numberOfBits, bits: bits)
                    outputs.append(signal)
                }
            }
        }
        return (inputs: inputs, outputs: outputs)
    }
    fileprivate func extractInternalSignals(from globalSignals: [GlobalSignal]) -> [Signal] {
        var signals: [Signal] = []
        globalSignals.forEach {
            switch $0.type {
            case .standardLogic:
                let signal = SingleBitSignal(associatedId: $0.name, value: .negative)
                signals.append(signal)
            case .standardLogicVector:
                let bits = [StandardLogicValue].init(repeating: .negative, count: $0.numberOfBits)
                let signal = MultiBitSignal(associatedId: $0.name, numberOfBits: $0.numberOfBits, bits: bits)
                signals.append(signal)
            }
        }
        
        return signals
    }
    fileprivate func extractLogicFunctions(from descriptors: [LogicDescriptor], availableInputSignals inputs: [Signal], availableOutputSignals outputs: [Signal]) -> [SignalKey: LogicFunction] {
    
        var mapping = [SignalKey: LogicFunction]()
        descriptors.forEach {
            switch $0.elementType {
            case .combinational:
                switch $0.logicOperation {
                case .and:
                    for input
                case .or:
                case .none:
                }
            case .sequential:
                fatalError("Sequential Module Extraction not Implemented Yet")
            case .connection:
                break
            }
        }
        
        return mapping
    }
    
}
