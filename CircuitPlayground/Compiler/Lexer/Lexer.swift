//
//  Lexer.swift
//  CircuitPlaygroundCompiler
//
//  Created by Nicolas Nascimento on 26/02/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Lexer {
    
    // MARK: - Public
    let input: String
    
    // MARK: - Private
    private var currentIndex: String.Index
}

extension Lexer {

    // MARK: - Initialization
    init(input: String) {
        self.input = input
        self.currentIndex = input.startIndex
    }
    
    mutating func lex() -> [Token] {
        var tokens: [Token] = []
        while let token = self.advanceToNextToken() {
            
            if let composedElement = token.type as? ComposedElement {
                switch composedElement {
                case .multipleTokens(let multipleTokens): tokens.append(contentsOf: multipleTokens)
                default: tokens.append(token)
                }
            } else {
                tokens.append(token)
            }
        }
        return tokens
    }
}

extension Lexer {
    
    private mutating func advanceToNextToken() -> Token? {
        if self.currentIndex != self.input.endIndex {
            
            // Skip comments and spaces
            while self.attempToskipCommentsAndSpaces() { }
            
            // Check if eof has been obtained
            if self.input.endIndex == self.currentIndex {
                return Token(type: FileCheckPoint.eof)
            }
            
            // Check for parenthesis
            if let parenthesis: PrecedenceOperator = self.attempToExtract() {
                return self.advanceCurrentIndex(by: parenthesis.rawValue.count, andCreateTokenFor: parenthesis)
            }
            
            // Check for Ponctuaction
            if let ponctuation: Ponctuation = self.attempToExtract() {
                return self.advanceCurrentIndex(by: ponctuation.rawValue.count, andCreateTokenFor: ponctuation)
            }
            
            // Check for keyword
            if let keyword: Keyword = self.attempToExtract(requiresWord: true) {
                return self.advanceCurrentIndex(by: keyword.rawValue.count, andCreateTokenFor: keyword)
            }
            
            // Shift
            if let shift: Shift = self.attempToExtract(requiresWord: true) {
                return self.advanceCurrentIndex(by: shift.rawValue.count, andCreateTokenFor: ComposedElement.operator(shift))
            }
            
            // Relational
            if let relational: Relational = self.attempToExtract(requiresWord: true) {
                return self.advanceCurrentIndex(by: relational.rawValue.count, andCreateTokenFor: ComposedElement.operator(relational))
            }
            
            // Logic
            if let logic: Logic = self.attempToExtract(requiresWord: true) {
                return self.advanceCurrentIndex(by: logic.rawValue.count, andCreateTokenFor: ComposedElement.operator(logic))
            }
            
            // Assignment
            if let assignment: Assignment = self.attempToExtract(requiresWord: true) {
                return self.advanceCurrentIndex(by: assignment.rawValue.count, andCreateTokenFor: ComposedElement.operator(assignment))
            }
            
            // Miscelaneous
            if let miscelaneous: Miscelaneous = self.attempToExtract() {
                return self.advanceCurrentIndex(by: miscelaneous.rawValue.count, andCreateTokenFor: ComposedElement.operator(miscelaneous))
            }
            
            // Identifier & Number
            if let compoundToken = self.attempToExtractIdentifierOrNumber() {
                return compoundToken
            }
            
        }
        return nil
    }
    

    
    private mutating func attempToExtractIdentifierOrNumber() -> Token? {
        
        var tokens: [Token] = []
        var additionalTokens: [Token] = []
        
        // Number and identifier
        if var stringValue: String = self.currentWord() {
            let wordLength = stringValue.count
            
            // Check if user typed additional Token together with and identifier or number
            
            while let additionalTokenType: TokenType = self.attempToExtractPonctuation(from: stringValue) ?? self.attempToExtractPrecedenceOperator(from: stringValue) {
                let additionalToken = Token(type: additionalTokenType)
                additionalTokens.append(additionalToken)
                
                // Remove Last Element if needed
                let rawValue: String = additionalToken.type.stringValue
                stringValue = String(stringValue.dropLast(rawValue.count))
                
            }
            
            // Extract number of identifier
            if let doubleValue = Double(stringValue) {
                let numberToken = self.advanceCurrentIndex(by: wordLength, andCreateTokenFor: ComposedElement.number(doubleValue))
                tokens.append(numberToken)
            } else {
                let identifier = self.advanceCurrentIndex(by: wordLength, andCreateTokenFor: ComposedElement.identifier(stringValue))
                tokens.append(identifier)
            }
            
            // Add additional Token if found
            tokens.append(contentsOf: additionalTokens.reversed())

            // Switch on amount of tokens
            switch tokens.count {
            // If we only have one token, return it
            case 1: return tokens.first!
                
            // If we have multiple tokens, return as a composed element
            case 2...: return Token(type: ComposedElement.multipleTokens(tokens))
            default: return nil
            }
            
        }
        return nil
    }
    
    
    private func attempToExtractPonctuation(from word: String) -> Ponctuation? {
        // Check if Ponctuation is even allowed
        let characterToTest = self.input[self.input.index(self.currentIndex, offsetBy: word.count)]
        
        var ponctuation: Ponctuation?
        // Attemp to extract ponctuation from the end of word
        if let lastCharacter = word.last {
            if let extractedPonctuation = Ponctuation(rawValue: String(lastCharacter)) {
                ponctuation = extractedPonctuation
            }
        }
        
        if ponctuation == .semicolon && !(characterToTest.isNewLineIndicator || characterToTest.isWhiteSpace) {
            return nil
        }
        
        return ponctuation
    }
    
    private func attempToExtractPrecedenceOperator(from word: String) -> PrecedenceOperator? {
        
        var precedenceOperator: PrecedenceOperator?
        // Attemp to extract precedence operator from the end of word
        if let lastCharacter = word.last {
            if let extractedPrecedenceOperator = PrecedenceOperator(rawValue: String(lastCharacter)) {
                precedenceOperator = extractedPrecedenceOperator
            }
        }
        return precedenceOperator
    }
    
    
    private mutating func attempToskipCommentsAndSpaces() -> Bool {
        
        // Amount of characters left
        let distanceToEndOfFile = self.input.distance(from: self.currentIndex, to: self.input.endIndex)
        
        // If we have less than 2 characters left, there's no way we can have a comment
        // In this case, simply skip characters
        
        // Save original index for comparision afterwards
        let originalIndex = self.currentIndex
        
        if distanceToEndOfFile < 2 {
            self.currentIndex = self.input.index(self.currentIndex, offsetBy: distanceToEndOfFile)
        } else {

            // Check if a comment is possible
            if self.input[self.currentIndex] == "-" && self.input[self.input.index(after: self.currentIndex)] == "-" {
                
                // Skip comment line
                while !self.input[self.currentIndex].isNewLineIndicator {
                    self.currentIndex = self.input.index(after: self.currentIndex)
                    
                    // Avoid eof
                    if self.input.endIndex == self.currentIndex {
                        return false
                    }
                }
            }
            
            // Skip Line indicators
            while self.input[self.currentIndex].isNewLineIndicator {
                self.currentIndex = self.input.index(after: self.currentIndex)
                
                // Avoid eof
                if self.input.endIndex == self.currentIndex {
                    return false
                }
            }
            
            // Skip white spaces
            while self.input[self.currentIndex].isWhiteSpace {
                self.currentIndex = self.input.index(after: self.currentIndex)
                
                // Avoid eof
                if self.input.endIndex == self.currentIndex {
                    return false
                }
            }
            
            // Skip tabs
            while self.input[self.currentIndex].isTabSpace {
                self.currentIndex = self.input.index(after: self.currentIndex)
                
                // Avoid eof
                if self.input.endIndex == self.currentIndex {
                    return false
                }
            }
            
            
        }
        
        return self.currentIndex != originalIndex
    }
    
    private mutating func advanceCurrentIndex(by offset: Int, andCreateTokenFor tokenType: TokenType) -> Token {
        // Advance Index
        self.currentIndex = self.input.index(self.currentIndex, offsetBy: offset)
        
        // Return Token
        return Token(type: tokenType)
    }
    
    private func attempToExtract<T>(requiresWord: Bool = false) -> T? where T: RawRepresentable, T.RawValue == String {
        
        var word: String
        if requiresWord {
            guard let currentWord = self.currentWord(), !currentWord.isEmpty else { return nil }
            guard let filteredWordCharacter = currentWord.split(separator: "(").first else { return nil }
            
            var filteredWord = String(filteredWordCharacter)
            var lastCharacter = String(filteredWord[filteredWord.index(before: filteredWord.endIndex)])

            while let _ = Ponctuation(rawValue: lastCharacter) {
                
                // Remove Last Ponctuation
                filteredWord = String(filteredWord.dropLast())
            
                // Update Last Character
                lastCharacter = String(filteredWord[filteredWord.index(before: filteredWord.endIndex)])
            }
            
            word = String(filteredWord)
        } else {
            word = String(self.input[self.currentIndex])
        }
        
        return self.attempToExtract(from: word)
    }
    private func attempToExtract<T>(from word: String) -> T? where T: RawRepresentable, T.RawValue == String {

        return T(rawValue: word)
    }
    
}

extension Lexer {
    private func currentWord() -> String? {
        let currentBuffer = self.input[self.currentIndex...]
        
        guard let word = currentBuffer.split(separator: " ").first?.split(separator: ",").first?.split(separator: ".").first?.split(separator: "\n").first?.split(separator: "\r").first else { return nil }
        return String(word)
    }
}

extension RawRepresentable where RawValue == String {
    init?(firstPermutationFrom string: String) {
        
        for index in string.indices {
            let substring = string[string.startIndex...index]
            let string = String(substring)
            if Self.isValid(string) {
                self.init(rawValue: string)
                return
            }
        }
        return nil
    }
    
    static func isValid(_ string: String) -> Bool {
        return Self(rawValue: string) != nil
    }
}

// MARK: - Character
extension Character {
    
    fileprivate var isNewLineIndicator: Bool {
        switch self {
        case "\n", "\r": return true
        default: return false
        }
    }
    fileprivate var isWhiteSpace: Bool {
        return self == " "
    }
    fileprivate var isTabSpace: Bool {
        return self == "\t"
    }
    
}
