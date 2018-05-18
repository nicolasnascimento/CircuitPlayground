//
//  Expression.swift
//  CircuitPlaygroundCompiler
//
//  Created by Nicolas Nascimento on 01/03/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

// MARK: - VHDL
protocol Expression {
    var endsInSemicolon: Bool { get }
    var numberOfTokens: Int { get }
}

// MARK: - Default Implementation
extension Expression {
    var numberOfTokens: Int {
        return 1
    }

    var endsInSemicolon: Bool {
        return true
    }
}

extension Expression {
    
    // Shortcut for extracting list of expressions from a compound expression
    var list: [Expression] {
        return self as? [Expression] ?? [self]
    }
}

protocol ParserElement {
    var numberOfTokens: Int { get }
}

// Because this a very commom structure to be found in the end of expressions, assign it a struct
struct VHDLEndingKeyword: ParserElement {
    let endKeyword: Keyword
    let identifierKeyword: Keyword
    let semicolon: Ponctuation
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.endKeyword.numberOfTokens + self.identifierKeyword.numberOfTokens + self.semicolon.numberOfTokens }
}


// An identifier for a vhdl element
struct VHDLEndingIdentifier: ParserElement {
    let endKeyword: Keyword
    let identifier: VHDLIdentifier
    let semicolon: Ponctuation
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.endKeyword.numberOfTokens + self.identifier.numberOfTokens + self.semicolon.numberOfTokens }
}


// An identifier
struct VHDLIdentifier: ParserElement, Expression {
    let name: String
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return 1 }
    var endsInSemicolon: Bool { return false }
}

// A constant
struct VHDLConstant: ParserElement, Expression {
    enum RawType {
        case bit(Bool)
        case numeral(Double)
    }
    
    let rawType: RawType
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int {
        switch self.rawType {
        case .bit(_): return 3
        case .numeral(_): return 1
        }
    }
    
    var endsInSemicolon: Bool { return false }
}

// An expression inside parenthesis
struct VHDLParenthesized: ParserElement, Expression {
    let leftParethesis: PrecedenceOperator
    let rightParenthesis: PrecedenceOperator
    let expression: Expression
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.leftParethesis.numberOfTokens + self.expression.numberOfTokens + self.rightParenthesis.numberOfTokens }
    var endsInSemicolon: Bool { return false }
}

// A binary operation
struct VHDLBinaryOperation: ParserElement, Expression {
    let leftExpression: Expression
    let rightExpression: Expression
    let `operator`: Operator
    let semicolon: Ponctuation?
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.leftExpression.numberOfTokens + self.operator.numberOfTokens + self.rightExpression.numberOfTokens + (self.semicolon?.numberOfTokens ?? 0) }
}
// An unary operation
struct VHDLUnaryOperation: ParserElement, Expression {
    let rightExpression: Expression
    let `operator`: Operator
    let semicolon: Ponctuation?
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.operator.numberOfTokens + self.rightExpression.numberOfTokens + (self.semicolon?.numberOfTokens ?? 0) }
}

// A when else structure
struct VHDLWhenElse: ParserElement, Expression {
    var partialWhelElseExpressions: [VHDLPartialWhenElse]
    var defaultValue: Expression?
    var semicolon: Ponctuation?
    
    init?(partialWhenElseExpressions: [VHDLPartialWhenElse], defaultValue: Expression?, semicolon: Ponctuation?) {
        // Check if last expression has an else clause and providede ponctuaction is a semicolon
        if let possibleElse = partialWhenElseExpressions.last?.elseKeyword, possibleElse == .else, semicolon == .semicolon {
            self.partialWhelElseExpressions = partialWhenElseExpressions
            self.defaultValue = defaultValue
            self.semicolon = semicolon
        } else {
            return nil
        }
    }
    
    var numberOfTokens: Int { return partialWhelElseExpressions.reduce(0, {$0 + $1.numberOfTokens}) + (defaultValue?.numberOfTokens ?? 0) + (semicolon?.numberOfTokens ?? 0) }
}


struct VHDLPartialWhenElse: ParserElement, Expression {
    let leftExpression: Expression
    let whenKeyword: Keyword
    let booleanExpression: Expression
    let elseKeyword: Keyword
    
    var numberOfTokens: Int { return leftExpression.numberOfTokens + whenKeyword.numberOfTokens + booleanExpression.numberOfTokens + elseKeyword.numberOfTokens }
    var endsInSemicolon: Bool { return false }
}

// An if statement
struct VHDLIf: ParserElement, Expression {
    let ifKeyword: Keyword
    let booleanExpression: Expression
    let thenKeyword: Keyword
    let onTrueExpression: Expression
    let endIfKeywords: VHDLEndingKeyword
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.ifKeyword.numberOfTokens + self.booleanExpression.numberOfTokens + self.thenKeyword.numberOfTokens + self.onTrueExpression.numberOfTokens + self.endIfKeywords.numberOfTokens }
}

// An if else statement
struct VHDLIfElse: ParserElement, Expression {
    let ifKeyword: Keyword
    let booleanExpression: Expression
    let thenKeyword: Keyword
    let onTrueExpression: Expression
    let elseKeyword: Keyword
    let onFalseExpression: Expression
    let endIfKeywords: VHDLEndingKeyword
    
    // IMPORTANT: Adding a new property requires you to update this value to match is
    var numberOfTokens: Int { return self.ifKeyword.numberOfTokens + self.booleanExpression.numberOfTokens + self.thenKeyword.numberOfTokens + self.onTrueExpression.numberOfTokens + self.elseKeyword.numberOfTokens + self.onFalseExpression.numberOfTokens + self.endIfKeywords.numberOfTokens }
}

// An identifier (e.g name attributted to elements)
struct VHDLIdentifierList: ParserElement {
    let identifiers: [VHDLIdentifier]
    
    var numberOfTokens: Int {
        if identifiers.isEmpty {
            return 0
        }
        
        let identifierTokens = self.identifiers.reduce(0, {$0 + $1.numberOfTokens})
        let commaTokens = identifierTokens - 1
        return identifierTokens + commaTokens
    }
}

// A process declaration
struct VHDLProcess: ParserElement, Expression {
    let processKeyword: Keyword
    let leftParentthesis: PrecedenceOperator
    let identifierList: VHDLIdentifierList
    let rightParenthesis: PrecedenceOperator
    let beginKeyword: Keyword
    let expression: Expression
    let endProcessKeywords: VHDLEndingKeyword
    
    var numberOfTokens: Int {
        let tokens: [Int] = [self.processKeyword.numberOfTokens, self.leftParentthesis.numberOfTokens, self.identifierList.numberOfTokens, self.rightParenthesis.numberOfTokens, self.beginKeyword.numberOfTokens, self.expression.numberOfTokens, self.endProcessKeywords.numberOfTokens]
        return tokens.reduce(0, { $0 + $1 })
    }
}

// A signal declared in
struct VHDLInternalSignalDeclaration: ParserElement {
    let signalKeyword: Keyword
    let identifier: VHDLIdentifier
    let colon: Ponctuation
    let typeIdentifier: VHDLIdentifier
    let semicolon: Ponctuation
    
    var numberOfTokens: Int {
        return self.signalKeyword.numberOfTokens + self.identifier.numberOfTokens + self.colon.numberOfTokens + self.typeIdentifier.numberOfTokens + self.semicolon.numberOfTokens
    }
}

struct VHDLInternalSignalDeclarationList {
    let signals: [VHDLInternalSignalDeclaration]
    var numberOfTokens: Int {
        return signals.reduce(0 , { $0 + $1.numberOfTokens })
    }
}

// An architecture definition
struct VHDLArchitecture: ParserElement, Expression {
    let architectureKeyword: Keyword
    let name: VHDLIdentifier
    let ofKeyword: Keyword
    let entityName: VHDLIdentifier
    let isKeyword: Keyword
    let beginKeyword: Keyword
    let signals: VHDLInternalSignalDeclarationList
    let expression: Expression
    let endArchitectureKeywords: VHDLEndingKeyword
    
    var numberOfTokens: Int {
        let signalTokens = self.signals.numberOfTokens
        let tokens: [Int] = [self.architectureKeyword.numberOfTokens, self.name.numberOfTokens + self.ofKeyword.numberOfTokens + self.entityName.numberOfTokens + self.isKeyword.numberOfTokens, signalTokens, self.beginKeyword.numberOfTokens, self.expression.numberOfTokens, self.endArchitectureKeywords.numberOfTokens]
        return tokens.reduce(0, { $0 + $1 })
    }
}

// An external signal declaration
struct VHDLExternalSignalDeclaration: ParserElement {
    let identifier: VHDLIdentifier
    let colon: Ponctuation
    let outputDirectionKeyword: Keyword
    let outputType: VHDLIdentifier
    
    var numberOfTokens: Int {
        return self.identifier.numberOfTokens + self.colon.numberOfTokens + self.outputDirectionKeyword.numberOfTokens + self.outputDirectionKeyword.numberOfTokens
    }
}

// An external signal declaration list
struct VHDLExternalSignalDeclarationList: ParserElement {
    let signals: [VHDLExternalSignalDeclaration]
    
    var numberOfTokens: Int {
        let value = signals.reduce(0 , { $0 + $1.numberOfTokens })
        if self.signals.count < 2 {
            return value
        } else {
            return value + (signals.count - 1) // For the semicolon
        }
    }
}

// A port declaration
struct VHDLPort: ParserElement {
    let portKeyword: Keyword
    let leftParenthesisKeyword: PrecedenceOperator
    let signals: VHDLExternalSignalDeclarationList
    let rightParethesis: PrecedenceOperator
    let semicolon: Ponctuation
    
    var numberOfTokens: Int {
        return self.portKeyword.numberOfTokens + self.leftParenthesisKeyword.numberOfTokens + self.signals.numberOfTokens + self.rightParethesis.numberOfTokens + self.semicolon.numberOfTokens
    }
}

// An entity definition
struct VHDLEntity: ParserElement, Expression {
    let entityKeyword: Keyword
    let name: VHDLIdentifier
    let isKeyword: Keyword
    let port: VHDLPort
    let endingIdentifier: VHDLEndingIdentifier
    
    var numberOfTokens: Int {
        return self.entityKeyword.numberOfTokens + self.name.numberOfTokens + self.isKeyword.numberOfTokens + self.port.numberOfTokens + self.endingIdentifier.numberOfTokens
    }
}

// A library declaration
struct VHDLLibrary: ParserElement, Expression {
    let libraryKeyword: Keyword
    let name: VHDLIdentifier
    let semicolon: Ponctuation
    
    var numberOfTokens: Int {
        return self.libraryKeyword.numberOfTokens + self.name.numberOfTokens + self.semicolon.numberOfTokens
    }
}


extension Array: Expression {
    var numberOfTokens: Int {
        let mapping = self.compactMap{ $0 as? Expression }
        return mapping.reduce(0, { $0 + $1.numberOfTokens })
    }
    var endsInSemicolon: Bool { return (self.last as? Expression)?.endsInSemicolon ?? false }
}


// An usage for a library definition
struct VHDLUse: ParserElement, Expression {
    let useKeyword: Keyword
    let firstIdentifer: VHDLIdentifier
    let firstDot: Ponctuation
    let secondIdentifier: VHDLIdentifier
    let secondDot: Ponctuation
    let thirdIdentifier: VHDLIdentifier
    let semicolon: Ponctuation
    
    var numberOfTokens: Int {
        let tokens: [Int] = [self.useKeyword.numberOfTokens, self.firstIdentifer.numberOfTokens, self.firstDot.numberOfTokens, self.secondDot.numberOfTokens, self.secondIdentifier.numberOfTokens, self.thirdIdentifier.numberOfTokens, self.semicolon.numberOfTokens]
        return tokens.reduce(into: 0, { $0 += $1 })
    }
}


