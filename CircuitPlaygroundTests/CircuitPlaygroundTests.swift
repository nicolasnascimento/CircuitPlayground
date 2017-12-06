//
//  CircuitPlaygroundTests.swift
//  CircuitPlaygroundTests
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import XCTest
@testable import CircuitPlayground

class CircuitPlaygroundTests: XCTestCase {
    
    func testSingleBitAndLogicFunction() {
        
        let bit1 = SingleBitSignal(associatedId: "x", value: .positive)
        let bit2 = SingleBitSignal(associatedId: "y", value: .positive)
        let bit3 = SingleBitSignal(associatedId: "z", value: .negative)

        // Test same bit equality
        XCTAssert(LogicFunctions.and([bit1, bit2]) == [.positive])
        
        // Test same value equality
        XCTAssert(LogicFunctions.and([bit1, bit1]) == [.positive])
        
        // Test value inequality
        XCTAssert(LogicFunctions.and([bit1, bit3]) == [.negative])
    
        // Test multiple bit inequality
        XCTAssert(LogicFunctions.and([bit1, bit2, bit3]) == [.negative])
    }
    
    func testSingleBitOrLogicFunction() {
        
        let bit1 = SingleBitSignal(associatedId: "x", value: .positive)
        let bit2 = SingleBitSignal(associatedId: "y", value: .positive)
        let bit3 = SingleBitSignal(associatedId: "z", value: .negative)
        
        
        // Test same bit equality
        XCTAssert(LogicFunctions.or([bit1, bit2]) == [.positive])
        
        // Test same value equality
        XCTAssert(LogicFunctions.or([bit1, bit1]) == [.positive])
        
        // Test same value equality
        XCTAssert(LogicFunctions.or([bit3, bit3, bit3]) == [.negative])
        
        // Test value inequality
        XCTAssert(LogicFunctions.or([bit1, bit3]) == [.positive])
        
        // Test multiple bit inequality
        XCTAssert(LogicFunctions.or([bit1, bit2, bit3]) == [.positive])
    }
    
    func testSingleBitNotLogicFunction() {
        
        let bit = SingleBitSignal(associatedId: "x", value: .positive)
        
        XCTAssert(LogicFunctions.not([bit]) == [.negative])
    }
    
    func testMultiBitAndLogicFunction() {
        
        let signal1 = MultiBitSignal(associatedId: "x", numberOfBits: 2, bits: [.positive, .positive])
        let signal2 = MultiBitSignal(associatedId: "y", numberOfBits: 2, bits: [.negative, .negative])
        let signal3 = MultiBitSignal(associatedId: "w", numberOfBits: 2, bits: [.positive, .negative])
        let signal4 = MultiBitSignal(associatedId: "z", numberOfBits: 2, bits: [.negative, .positive])
        
        // Test same bit equality
        XCTAssert(LogicFunctions.and([signal1, signal2]) == [.negative, .negative])
        
        // Test same value equality
        XCTAssert(LogicFunctions.and([signal1, signal1]) == signal1.bits)

        // Test value inequality
        XCTAssert(LogicFunctions.and([signal1, signal3]) == [.positive, .negative])

        // Test multiple bit inequality
        XCTAssert(LogicFunctions.and([signal1, signal2, signal3, signal4]) == [.negative, .negative])
    }
    
    func testMultiBitOrLogicFunction() {
        
        let signal1 = MultiBitSignal(associatedId: "x", numberOfBits: 2, bits: [.positive, .positive])
        let signal2 = MultiBitSignal(associatedId: "y", numberOfBits: 2, bits: [.negative, .negative])
        let signal3 = MultiBitSignal(associatedId: "w", numberOfBits: 2, bits: [.positive, .negative])
        let signal4 = MultiBitSignal(associatedId: "z", numberOfBits: 2, bits: [.negative, .positive])
        
        // Test same bit equality
        XCTAssert(LogicFunctions.or([signal1, signal2]) == [.positive, .positive])
        
        // Test same value equality
        XCTAssert(LogicFunctions.or([signal2, signal3]) == [.positive, .negative])
        
        // Test value inequality
        XCTAssert(LogicFunctions.or([signal1, signal3]) == [.positive, .positive])
        
        // Test multiple bit inequality
        XCTAssert(LogicFunctions.or([signal1, signal2, signal3, signal4]) == [.positive, .positive])
    }
    
    func testMultiBitNotLogicFunction() {
        
        let signal1 = MultiBitSignal(associatedId: "x", numberOfBits: 2, bits: [.positive, .positive])
        
        // Test same bit equality
        XCTAssert(LogicFunctions.not([signal1]) == [.negative, .negative])
    }
    
}
