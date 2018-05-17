//
//  Parser.swift
//  CircuitPlaygroundCompiler
//
//  Created by Nicolas Nascimento on 01/03/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct Parser {
    var tokens: [Token]
    
    // MARK: - Private
    private var currentIndex = 0
    private var currentToken: Token? { return self.tokens.indices.contains(self.currentIndex) ? self.tokens[currentIndex] : nil }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
}

enum ParserError: Error {
    case unknown(String)
}

extension Parser {
    
    mutating func parseFile() throws -> [Expression] {
        var expressions: [Expression] = []
        
        while let expression = try self.extractExpressionFromCurrentToken() {
            expressions.append(expression)
            self.currentIndex += expression.numberOfTokens
        }
        
        return expressions
    }
}

// MARK: - Private
extension Parser {

    private func extractLeastComplexExpressionFromCurrentToken(with token: Token, offset: Int) throws -> Expression? {
        // The expression to be returned
        var expression: Expression?
        
        // Depending on the type of token, we have to extract a different strucuture
        switch token.type {
        case let type as Keyword:
            switch type {
            case .library: expression = try self.extractLibraryFromCurrentToken()
            case .use: expression = try self.extractUseFromCurrentToken()
            case .if:
                do {
                    expression = try self.extractIfElseFromCurrentToken(offsetting: offset)
                } catch {
                    expression = try self.extractIfFromCurrentToken(offsetting: offset)
                }
            case .entity: expression = try self.extractEntityFromCurrentToken()
            case .architecture: expression = try self.extractArchitectureFromCurrentToken()
            case .process: expression = try self.extractProcessFromCurrentToken(offsetting: offset)
            default: expression = nil
            }
        case let operatorType as PrecedenceOperator:
            switch operatorType {
            case .leftParenthesis: expression = try self.extractParenthesizedExpressionFromCurrentToken()
            case .rightParenthesis: expression = nil
            }
        case let logicNot as Logic: expression = try extractUnaryOperationFromCurrentToken(with: offset, logicNot: logicNot)
        case let composedElement as ComposedElement:
            switch composedElement {
            case .identifier(let value): expression = VHDLIdentifier(name: value)
            case .number(let number): expression = VHDLConstant(rawType: .numeral(number))
            case .operator(let type):
                if let rightExpresison = try self.extractExpressionFromCurrentToken(offset: offset + type.numberOfTokens), let possibleSemicolon = (self.currentToken(offsetBy: offset + type.numberOfTokens + rightExpresison.numberOfTokens)?.type as? Ponctuation) {
                    let semicolon = possibleSemicolon  == .semicolon ? possibleSemicolon : nil
                    expression = VHDLUnaryOperation(rightExpression: rightExpresison, operator: type, semicolon: semicolon)
                }
            default: break
            }
        case let ponctuation as Ponctuation:
            switch ponctuation {
            case .apostrophe:
                guard let constantValue = self.currentToken(offsetBy: offset + 1)?.type as? ComposedElement else { break }
                switch constantValue {
                case .number(let value): return VHDLConstant(rawType: .bit(value == 1))
                default: break
                }
            default: break
            }
        default: break
        }
        
        return expression
    }
    
    private func extractExpressionFromCurrentToken(offset: Int = 0) throws -> Expression? {
        guard let token = self.currentToken(offsetBy: offset) else { return nil }
        
        // Extract first level of expression
        var expression = try self.extractLeastComplexExpressionFromCurrentToken(with: token, offset: offset)
        
        // Attemp composing expression to form a more complex one
        if let composedExpression = try self.attempExtractingComposedExpressionFromCurrentToken(with: expression, offset: offset) {
            expression = composedExpression
        }
        
        // Return fina expression
        return expression
    }
    
    private func extractParenthesizedExpressionFromCurrentToken() throws -> VHDLParenthesized {
        guard let firstElement = self.currentToken?.type as? PrecedenceOperator, firstElement == .leftParenthesis,
        let secondElement = try self.extractExpressionFromCurrentToken(offset: 1),
        let thirdElement = (self.currentToken(offsetBy: 1 + secondElement.numberOfTokens)?.type as? PrecedenceOperator), thirdElement == .rightParenthesis else { throw ParserError.unknown("Error parsing Parenthesis") }
        
        return VHDLParenthesized(leftParethesis: firstElement, rightParenthesis: thirdElement, expression: secondElement)
    }
    
    private func extractUnaryOperationFromCurrentToken(with offset: Int, logicNot: Logic) throws -> Expression? {
        guard let rightExpresison = try self.extractExpressionFromCurrentToken(), let possibleSemicolon = (self.currentToken(offsetBy: offset + logicNot.numberOfTokens + rightExpresison.numberOfTokens)?.type as? Ponctuation) else { return nil }
        let semicolon = possibleSemicolon  == .semicolon ? possibleSemicolon : nil
        return VHDLUnaryOperation(rightExpression: rightExpresison, operator: logicNot, semicolon: semicolon)
    }
    
    private func extractProcessFromCurrentToken(offsetting: Int) throws -> VHDLProcess {
        guard let firstElement = (self.currentToken(offsetBy: offsetting)?.type as? Keyword),
        let secondElement = (self.currentToken(offsetBy: offsetting + 1)?.type as? PrecedenceOperator),
        let thirdElement = try self.extractIdentifierListFromCurrentToken(with: offsetting + 2),
        let fourthElement = (self.currentToken(offsetBy: offsetting + 2 + thirdElement.numberOfTokens)?.type as? PrecedenceOperator),
        let fifthElement = (self.currentToken(offsetBy: offsetting + 3 + thirdElement.numberOfTokens)?.type as? Keyword),
        let sixthElement = try self.extractExpressionFromCurrentToken(offset: offsetting + 4 + thirdElement.numberOfTokens),
        let seventhElement = (self.currentToken(offsetBy: offsetting + 4 + thirdElement.numberOfTokens + sixthElement.numberOfTokens)?.type as? Keyword),
        let eighthElement = (self.currentToken(offsetBy: offsetting + 5 + thirdElement.numberOfTokens + sixthElement.numberOfTokens)?.type as? Keyword),
        let ninethElement = (self.currentToken(offsetBy: offsetting + 6 + thirdElement.numberOfTokens + sixthElement.numberOfTokens)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Process") }
        
        
        switch (firstElement, secondElement, thirdElement, fourthElement, fifthElement, sixthElement, seventhElement, eighthElement, ninethElement) {
        case (.process, .leftParenthesis, _, .rightParenthesis, .begin, _, .end, .process, .semicolon):
            let ending = VHDLEndingKeyword(endKeyword: .end, identifierKeyword: .process, semicolon: .semicolon)
            return VHDLProcess(processKeyword: .process, leftParentthesis: .leftParenthesis, identifierList: thirdElement, rightParenthesis: .rightParenthesis, beginKeyword: .begin, expression: sixthElement, endProcessKeywords: ending)
            
        default: throw ParserError.unknown("Error parsing Process")
        }
    }
    
    private func extractLibraryFromCurrentToken() throws -> VHDLLibrary {
        guard let firstTokenType = (self.currentToken?.type as? Keyword),
            let secondTokenType = (self.currentToken(offsetBy: 1)?.type as? ComposedElement),
            let thirdTokenType = self.currentToken(offsetBy: 2)?.type as? Ponctuation else { throw ParserError.unknown("Error parsing Library") }
        
        switch (firstTokenType, secondTokenType, thirdTokenType) {
        case (.library, .identifier(let value), .semicolon):
            return VHDLLibrary(libraryKeyword: firstTokenType, name: VHDLIdentifier(name: value), semicolon: thirdTokenType)
        default:  throw ParserError.unknown("Error Parsing Library")
        }
    }
    
    private func extractUseFromCurrentToken() throws -> VHDLUse {
        guard let firstTokenType = (self.currentToken?.type as? Keyword),
        let secondTokenType = (self.currentToken(offsetBy: 1)?.type as? ComposedElement),
        let thirdTokenType = (self.currentToken(offsetBy: 2)?.type as? Ponctuation),
        let fourthTokenType = (self.currentToken(offsetBy: 3)?.type as? ComposedElement),
        let fifthTokenType = (self.currentToken(offsetBy: 4)?.type as? Ponctuation),
        let sixthTokenType = (self.currentToken(offsetBy: 5)?.type as? ComposedElement),
            let seventhTokenType = (self.currentToken(offsetBy: 6)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Use") }
        
        switch (firstTokenType, secondTokenType, thirdTokenType, fourthTokenType, fifthTokenType, sixthTokenType, seventhTokenType) {
        case (.use, .identifier(let firstValue), .dot, .identifier(let secondValue), .dot, .identifier(let thirdValue), .semicolon):
            
            return VHDLUse(useKeyword: .use, firstIdentifer: VHDLIdentifier(name: firstValue), firstDot: .dot, secondIdentifier: VHDLIdentifier(name: secondValue), secondDot: .dot, thirdIdentifier: VHDLIdentifier(name: thirdValue), semicolon: .semicolon)
        default:
            throw ParserError.unknown("Error parsing Use")
        }
    }
    
    private func extractIfFromCurrentToken(offsetting: Int) throws -> VHDLIf {
        guard let firstElement = (self.currentToken(offsetBy: offsetting)?.type as? Keyword),
        let secondElement = try self.extractExpressionFromCurrentToken(offset: offsetting + 1),
        let thirdElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + 1)?.type as? Keyword),
        let fourthElement = try self.extractExpressionFromCurrentToken(offset: offsetting + secondElement.numberOfTokens + 2),
        let fifthElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + 2)?.type as? Keyword),
        let sixthElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + 3)?.type as? Keyword),
        let seventhElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + 4)?.type as? Ponctuation)else { throw ParserError.unknown("Error parsing If") }
        
        switch (firstElement, thirdElement, fifthElement, sixthElement, seventhElement) {
        case (.if, .then, .end, .if, .semicolon):
            let ending = VHDLEndingKeyword(endKeyword: .end, identifierKeyword: .if, semicolon: .semicolon)
            return VHDLIf(ifKeyword: .if, booleanExpression: secondElement, thenKeyword: .then, onTrueExpression: fourthElement, endIfKeywords: ending)
        default:
            throw ParserError.unknown("Error Parsing If")
        }
    }
    
    private func extractIfElseFromCurrentToken(offsetting: Int) throws -> VHDLIfElse {
        guard let firstElement = (self.currentToken(offsetBy: offsetting)?.type as? Keyword),
            let secondElement = try self.extractExpressionFromCurrentToken(offset: offsetting + 1),
            let thirdElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + 1)?.type as? Keyword),
            let fourthElement = try self.extractExpressionFromCurrentToken(offset: offsetting + secondElement.numberOfTokens + 2),
            let fifthElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + 2)?.type as? Keyword),
            let sixthElement = try self.extractExpressionFromCurrentToken(offset: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + 3),
            let seventhElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + sixthElement.numberOfTokens + 3)?.type as? Keyword),
            let eighthElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + sixthElement.numberOfTokens + 4)?.type as? Keyword),
            let ninethElement = (self.currentToken(offsetBy: offsetting + secondElement.numberOfTokens + fourthElement.numberOfTokens + sixthElement.numberOfTokens + 5)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing If-Else") }
        
        switch (firstElement, thirdElement, fifthElement, seventhElement, eighthElement, ninethElement) {
        case (.if, .then, .else, .end, .if, .semicolon):
            let ending = VHDLEndingKeyword(endKeyword: .end, identifierKeyword: .if, semicolon: .semicolon)
            return VHDLIfElse(ifKeyword: .if, booleanExpression: secondElement, thenKeyword: .then, onTrueExpression: fourthElement, elseKeyword: .else, onFalseExpression: sixthElement, endIfKeywords: ending)
        default:
            throw ParserError.unknown("Error parsing If-Else")
        }
    }
    
    private func extractArchitectureFromCurrentToken() throws -> VHDLArchitecture {
        guard let firstElement = (self.currentToken?.type as? Keyword),
        let secondElement = (self.currentToken(offsetBy: 1)?.type as? ComposedElement),
        let thirdElement = (self.currentToken(offsetBy: 2)?.type as? Keyword),
        let fourthElement = (self.currentToken(offsetBy: 3)?.type as? ComposedElement),
        let fifthElement = (self.currentToken(offsetBy: 4)?.type as? Keyword),
        let sixthElement = try self.extractInternalSignalDeclarationListFromCurrentToken(with: 5),
        let seventhElement = (self.currentToken(offsetBy: 5 + sixthElement.numberOfTokens)?.type as? Keyword) else { throw ParserError.unknown("Error parsing Architecture Default Initialization")}

        // Loop through all expressions
        var eightElements: [Expression] = []
        var eightElementsNumberOfTokens = 0//eightElements.reduce(0, { $0 + $1.numberOfTokens })
        while let expression = try self.extractExpressionFromCurrentToken(offset: 6 + sixthElement.numberOfTokens + eightElementsNumberOfTokens) {
            eightElements.append(expression)
            eightElementsNumberOfTokens += expression.numberOfTokens
        }
        
        guard let ninethElement = (self.currentToken(offsetBy: 6 + sixthElement.numberOfTokens + eightElementsNumberOfTokens)?.type as? Keyword),
        let tenthElement = (self.currentToken(offsetBy: 7 + sixthElement.numberOfTokens + eightElementsNumberOfTokens)?.type as? Keyword),
        let eleventhElement = (self.currentToken(offsetBy: 8 + sixthElement.numberOfTokens + eightElementsNumberOfTokens)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Architecture") }
     
        switch (firstElement, secondElement, thirdElement, fourthElement, fifthElement, sixthElement, seventhElement, eightElements, ninethElement, tenthElement, eleventhElement) {
        case (.architecture, .identifier(let firstValue), .of, .identifier(let secondValue), .is, _, .begin, _, .end, .architecture, .semicolon):
            
            let ending = VHDLEndingKeyword(endKeyword: .end, identifierKeyword: .architecture, semicolon: .semicolon)
            
            return VHDLArchitecture(architectureKeyword: .architecture, name: VHDLIdentifier(name: firstValue), ofKeyword: .of, entityName: VHDLIdentifier(name: secondValue), isKeyword: .is, beginKeyword: .begin, signals: sixthElement, expression: eightElements, endArchitectureKeywords: ending)
            
        default: throw ParserError.unknown("Error parsing Architecture")
        }
        
    }
    
    private func extractEntityFromCurrentToken() throws -> VHDLEntity {
        guard let firstElement = (self.currentToken?.type as? Keyword),
        let secondElement = (self.currentToken(offsetBy: 1)?.type as? ComposedElement),
        let thirdElement = (self.currentToken(offsetBy: 2)?.type as? Keyword),
        let fourthElement = try self.extractPortFromCurrentToken(with: 3),
        let fifthElement = (self.currentToken(offsetBy: 3 + fourthElement.numberOfTokens)?.type as? Keyword),
        let sixthElement = (self.currentToken(offsetBy: 4 + fourthElement.numberOfTokens)?.type as? ComposedElement),
        let seventhElement = (self.currentToken(offsetBy: 5 + fourthElement.numberOfTokens)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Entity") }
    
        switch (firstElement, secondElement, thirdElement, fifthElement, sixthElement, seventhElement) {
        case (.entity, .identifier(let value), .is, .end, .identifier(let secondValue), .semicolon):
            let ending = VHDLEndingIdentifier(endKeyword: .end, identifier: VHDLIdentifier(name: secondValue), semicolon: .semicolon)
            return VHDLEntity(entityKeyword: .entity, name: VHDLIdentifier(name: value), isKeyword: .is, port: fourthElement, endingIdentifier: ending)
        default:  throw ParserError.unknown("Error parsing Entity")
        }
    }
    
    private func extractPortFromCurrentToken(with offset: Int) throws -> VHDLPort? {
        
        guard let firstElement = (self.currentToken(offsetBy: offset)?.type as? Keyword),
        let secondElement = (self.currentToken(offsetBy: offset + 1)?.type as? PrecedenceOperator),
        let thirdElement = try self.extractExternalSignalDeclarationListFromCurrentToken(with: offset + 2),
        let fourthElement = (self.currentToken(offsetBy: offset + 2 + thirdElement.numberOfTokens)?.type as? PrecedenceOperator),
        let fifthElement = (self.currentToken(offsetBy: offset + 3 + thirdElement.numberOfTokens)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Port") }
        
        switch (firstElement, secondElement, thirdElement, fourthElement, fifthElement) {
        case (.port, .leftParenthesis, _, .rightParenthesis, .semicolon):
            return VHDLPort(portKeyword: .port, leftParenthesisKeyword: .leftParenthesis, signals: thirdElement, rightParethesis: .rightParenthesis, semicolon: .semicolon)
        default: throw ParserError.unknown("Error parsing Port")
        }
        
        
    }
    
    private func extractExternalSignalDeclarationListFromCurrentToken(with offset: Int) throws -> VHDLExternalSignalDeclarationList? {
        var signals: [VHDLExternalSignalDeclaration] = []
        var currentOffset = offset
        
        var shouldLoop = true
        while shouldLoop {
            shouldLoop = false
            do {
                let signal = try self.extractExternalSignalDeclarationFromCurrentToken(with: currentOffset)
                signals.append(signal)
                currentOffset += signal.numberOfTokens + 1 // Signal Tokens + Semicolon
                shouldLoop = true
            } catch {
                shouldLoop = false
            }
        }
        
        if signals.isEmpty {
            throw ParserError.unknown("Error parsing External Signals List")
        }
        
        return VHDLExternalSignalDeclarationList(signals: signals)
    }
    
    private func extractInternalSignalDeclarationListFromCurrentToken(with offset: Int) throws -> VHDLInternalSignalDeclarationList? {
        
        // Avoid empty internal signal list
        if let currentKeyword = (self.currentToken(offsetBy: offset)?.type as? Keyword), currentKeyword == .begin {
            return VHDLInternalSignalDeclarationList(signals: [])
        }
        
        var signals: [VHDLInternalSignalDeclaration] = []
        var currentOffset = offset
        
        while true {
            do {
                let signal = try self.extractInternalSignalDeclarationFromCurrentToken(with: currentOffset)
                signals.append(signal)
                currentOffset += signal.numberOfTokens
            } catch {
                break
            }
        }
        
        if signals.isEmpty {
            throw ParserError.unknown("Error parsing Internal Signals List")
        }
        
        return VHDLInternalSignalDeclarationList(signals: signals)
    }
    
    private func extractInternalSignalDeclarationFromCurrentToken(with offset: Int) throws -> VHDLInternalSignalDeclaration {
        guard let firstElement = (self.currentToken(offsetBy: offset)?.type as? Keyword),
        let secondElement = (self.currentToken(offsetBy: offset + 1)?.type as? ComposedElement),
        let thirdElement = (self.currentToken(offsetBy: offset + 2)?.type as? Ponctuation),
        let fourthElement = (self.currentToken(offsetBy: offset + 3)?.type as? ComposedElement),
        let fifthElement = (self.currentToken(offsetBy: offset + 4)?.type as? Ponctuation) else { throw ParserError.unknown("Error parsing Internal Signal") }
        
        switch (firstElement, secondElement, thirdElement, fourthElement, fifthElement) {
        case (.signal, .identifier(let firstValue), .colon, .identifier(let secondValue), .semicolon):
            return VHDLInternalSignalDeclaration(signalKeyword: .signal, identifier: VHDLIdentifier(name: firstValue), colon: .colon, typeIdentifier: VHDLIdentifier(name: secondValue), semicolon: .semicolon)
        default: throw ParserError.unknown("Error parsing Internal Signal")
        }
        
    }
    
    private func attempExtractingComposedExpressionFromCurrentToken(with currentExpression: Expression?, offset: Int) throws -> Expression? {
        // The expression to be returned
        var expression: Expression?
        
        // First, attemp to extract binary operation
        if let currentExpression = currentExpression, let binaryOperation = try self.attempExtractingSignalAttibutionFromCurrentToken(with: currentExpression, offset: offset) {
            expression = binaryOperation
        }
        
        return expression
    }
    
    private func attempExtractingSignalAttibutionFromCurrentToken(with currentExpression: Expression, offset: Int) throws -> VHDLBinaryOperation? {
        let numberOfTokens = currentExpression.numberOfTokens
        guard let nextTokenType = self.currentToken(offsetBy: offset + numberOfTokens)?.type as? ComposedElement else { return nil }
        
        switch (nextTokenType) {
        case .operator(let operation):
            if let rightExpression = try self.extractExpressionFromCurrentToken(offset: offset + numberOfTokens + 1) {
                var possibleSemicolon: Ponctuation?
                if let semicolon = self.currentToken(offsetBy: offset + numberOfTokens + 1 + rightExpression.numberOfTokens)?.type as? Ponctuation, semicolon == .semicolon {
                     possibleSemicolon = .semicolon
                }
                return VHDLBinaryOperation(leftExpression: currentExpression, rightExpression: rightExpression, operator: operation, semicolon: possibleSemicolon)
            }
        default: break
        }
        return nil
    }
    
    private func extractExternalSignalDeclarationFromCurrentToken(with offset: Int) throws -> VHDLExternalSignalDeclaration {


        guard let firstElement = (self.currentToken(offsetBy: offset)?.type as? ComposedElement),
        let secondElement = (self.currentToken(offsetBy: offset + 1)?.type as? Ponctuation),
        let thirdElement = (self.currentToken(offsetBy: offset + 2)?.type as? Keyword),
        let fourthElement = (self.currentToken(offsetBy: offset + 3)?.type as? ComposedElement) else { throw ParserError.unknown("Error parsing External Signals") }
        
        
        switch (firstElement, secondElement, thirdElement, fourthElement) {
        case (.identifier(let firstValue), .colon, .in, .identifier(let secondValue)),
             (.identifier(let firstValue), .colon, .out, .identifier(let secondValue)):
            return VHDLExternalSignalDeclaration(identifier: VHDLIdentifier(name: firstValue), colon: .dot, outputDirectionKeyword: thirdElement, outputType: VHDLIdentifier(name: secondValue))
        default: throw ParserError.unknown("Error parsing External Signal")
        }
        
    }
    
    private func extractIdentifierListFromCurrentToken(with offset: Int) throws -> VHDLIdentifierList? {
        var identifiers: [VHDLIdentifier] = []
        var currentOffset = offset

        var shouldLoop = true
        while shouldLoop {
            shouldLoop = false
            // This means an identifier
            if let currentIdentifier = self.currentToken(offsetBy: currentOffset)?.type as? ComposedElement {
                switch currentIdentifier {
                case .identifier(let value):
                    let identifier = VHDLIdentifier(name: value)
                    identifiers.append(identifier)
                    currentOffset += identifier.numberOfTokens
                    shouldLoop = true
                default: shouldLoop = false
                }

            } else if let currentComma = (self.currentToken(offsetBy: currentOffset)?.type as? Ponctuation), currentComma == .comma {
                currentOffset += currentComma.numberOfTokens
                shouldLoop = true
            } else {
                break
            }
        }
        return VHDLIdentifierList(identifiers: identifiers)
    }
    
    private func currentToken(offsetBy n: Int) -> Token? {
        
        guard self.currentIndex + n < self.tokens.count else { return nil }
        return self.tokens[self.currentIndex + n]
    }
}
