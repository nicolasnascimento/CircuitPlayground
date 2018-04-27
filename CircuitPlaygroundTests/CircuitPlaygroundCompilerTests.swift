//
//  CircuitPlaygroundCompilerTests.swift
//  CircuitPlaygroundTests
//
//  Created by Nicolas Nascimento on 24/04/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import XCTest
@testable import CircuitPlayground

class CircuitPlaygroundCompilerTests: XCTestCase {
    
    func testLexer() throws {
        // Extract tokens
        let tokens = self.extractTokens()
        
        // 58 Valid tokens + EOF token
        XCTAssert(tokens.count == self.andCombinationalVHDLDescription.numberOfTokens)
    }

    func testSyntax() throws {
        var syntax = Parser(tokens: self.extractTokens())
        let expressions = try! syntax.parseFile()
        var synthetizer = SynthesisPerformer(expressions: expressions)
        let spec = synthetizer.extractLogicSpecification()
        print(spec)
    }
    
    private func extractTokens() -> [Token] {
        // A known vhdl description to be put to the test
        let vhdlDescription = self.andCombinationalVHDLDescription
        // Create the lexer
        var lexer = Lexer(input: vhdlDescription.text)
        // First Extract Tokens form Lexer
        return lexer.lex()
    }
}



extension CircuitPlaygroundCompilerTests {
    
    // IMPORTANT: Any updates to this description should be performed on both the file and the correcte number of tokens
    var andCombinationalVHDLDescription: (text: String, numberOfTokens: Int) {
        return
            (text: """
            -- Import IEEE defined STD_LOGIC types
            library ieee;
            use ieee.std_logic_1164.all;

            -- Define the basic entity
            entity ExampleEntity is
                port(
                    A: in std_logic;
                    B: in std_logic;
                    C: out std_logic
                );
            end ExampleEntity;


            -- Define the basic architecture
            architecture ExampleArchitecture of ExampleEntity is

                signal temp: std_logic;

            begin

                -- Perform 'AND' of 'A' and 'B'
                temp <= A and B;

                -- connect 'temp' to 'C
                C <= temp;

            end architecture ; -- ExampleArchitecture
            """,
         
             // 58 Valid tokens + EOF token
            numberOfTokens: 59)
    }
    
}
