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
    init(singleCircuitSpecification specification: LogicSpecification) {
        // Perform Initialization with empty description
        self.init(modules: [], connections: [])
        
        // Extract Main Module from Specification
        let entityModule = self.extractModule(from: specification)
        self.modules.append(entityModule)
    }
    
    private func extractModule(from specification: LogicSpecification) -> Module {
        var module = CombinationalModule(inputs: [], outputs: [], internalSignals: [], functions: [], auxiliarModules: [])
        
        // Extract Input and Output Ports
        let portTranslation = self.extractInputsAndOutputs(from: specification.entity.ports)
        module.inputs = portTranslation.inputs
        module.outputs = portTranslation.outputs
        
        // Extract Internal Signals
        module.internalSignals = self.extractInternalSignals(from: specification.architecture.globalSignals)
    
        // Extract Functions
        module.functions = self.extractLogicFunctions(from: specification.architecture.logicDescriptors, availableInputSignals: module.inputs + module.internalSignals, availableOutputSignals: module.outputs + module.internalSignals)
        
        // Return module
        return module
    }
    private func extractInputsAndOutputs(from ports: [Port]) -> (inputs: [Signal], outputs: [Signal]) {
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
                    let bits = [StandardLogicValue](repeating: .negative, count: $0.numberOfBits)
                    let signal = MultiBitSignal(associatedId: $0.name, numberOfBits: $0.numberOfBits, bits: bits)
                    outputs.append(signal)
                }
            }
        }
        return (inputs: inputs, outputs: outputs)
    }
    private func extractInternalSignals(from globalSignals: [GlobalSignal]) -> [Signal] {
        var signals: [Signal] = []
        globalSignals.forEach {
            switch $0.type {
            case .standardLogic:
                let signal = SingleBitSignal(associatedId: $0.name, value: .negative)
                signals.append(signal)
            case .standardLogicVector:
                let bits = [StandardLogicValue](repeating: .negative, count: $0.numberOfBits)
                let signal = MultiBitSignal(associatedId: $0.name, numberOfBits: $0.numberOfBits, bits: bits)
                signals.append(signal)
            }
        }
        return signals
    }
    private func extractLogicFunctions(from descriptors: [LogicDescriptor], availableInputSignals inputs: [Signal], availableOutputSignals outputs: [Signal]) -> [(inputs: [Signal], output: Signal, logicFunction: LogicFunctionDescriptor)] {
    
        var mapping:  [(inputs: [Signal], output: Signal, logicFunction: LogicFunctionDescriptor)]  = []
        descriptors.forEach {
            switch $0.elementType {
            case .sequential:
                fatalError("Sequential Module Extraction not Implemented Yet")
            default:
                // Get Inputs
                var associatedInputs: [Signal] = []
                for input in $0.inputs {
                    guard let associatedSignal = inputs.filter({ $0.associatedId == input.name }).first else { continue }
                    associatedInputs.append(associatedSignal)
                }
                
                var associatedOutput: Signal!
                for input in $0.outputs {
                    guard let associatedSignal = outputs.filter({ $0.associatedId == input.name }).first else { continue }
                    associatedOutput = associatedSignal
                    // Break as we only need 1 signal
                    break
                }
                
                switch $0.logicOperation {
                case .and:
                    let value = LogicFunctionDescriptor(logicDescriptor: .and, logicFunction: LogicFunctions.and)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .or:
                    let value = LogicFunctionDescriptor(logicDescriptor: .or, logicFunction: LogicFunctions.or)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .none:
                    let value = LogicFunctionDescriptor(logicDescriptor: .none, logicFunction: LogicFunctions.none)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .not:
                    let value = LogicFunctionDescriptor(logicDescriptor: .not, logicFunction: LogicFunctions.not)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .nand:
                    let value = LogicFunctionDescriptor(logicDescriptor: .nand, logicFunction: LogicFunctions.nand)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .nor:
                    let value = LogicFunctionDescriptor(logicDescriptor: .nor, logicFunction: LogicFunctions.nor)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .xor:
                    let value = LogicFunctionDescriptor(logicDescriptor: .xor, logicFunction: LogicFunctions.xor)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .xnor:
                    let value = LogicFunctionDescriptor(logicDescriptor: .xnor, logicFunction: LogicFunctions.xnor)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                case .mux:
                    // Note:
                    // Because we're only drawing the operations and not performing them, pass `none` as
                    // associated logic function
                    let value = LogicFunctionDescriptor(logicDescriptor: .mux, logicFunction: LogicFunctions.none)
                    mapping.append((inputs: associatedInputs, output: associatedOutput, logicFunction: value))
                }
            }
        }
        
        return mapping
    }
    
}
