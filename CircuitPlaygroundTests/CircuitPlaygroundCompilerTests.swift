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
    
    var tokens: [Token] = []
    
    func testLexer() throws {
        
        // A known vhdl description to be put to the test
        let vhdlDescription = self.andCombinationalVHDLDescription
        // Create the lexer
        var lexer = Lexer(input: vhdlDescription.text)
        
        // First Extract Tokens form Lexer
        self.tokens = lexer.lex()
        
        // 58 Valid tokens + EOF token
        XCTAssert(self.tokens.count == vhdlDescription.numberOfTokens)
    }

//    func testCompiler() throws {
//
//        let circuitFile = "/Users/nicolasnascimento/Dropbox (Personal)/TCC/CircuitPlayground/CircuitPlayground/Compiler/Sample/SingleBit/Combinational/and.vhd"
//
//        // Choose the sequential path
//        let path = circuitFile
//
//        // Construct URL from the path
//        let url = URL(fileURLWithPath: path)
//
//        print("Reading ...")
//        let data = try Data.init(contentsOf: url)
//        print("Done")
//        guard let textFromFile = String(data: data, encoding: .utf8) else { fatalError("Couldn't Extract Text From File") }
//        var lexer = Lexer(input: textFromFile)
//
//        print("Lexing ...")
//        // First Extract Tokens form Lexer
//        let tokens = lexer.lex()
//
//        XCTAssert(tokens.isEmpty == false)
//        print("Done")
//        // Next extract the expressions
//        var parser = Parser(tokens: tokens)
//        print("Parsing ...")
//        let expressions = try parser.parseFile()
//
//        XCTAssert(expressions.isEmpty == false)
//
//    }
    
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
