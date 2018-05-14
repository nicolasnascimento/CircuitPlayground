//
//  Token.swift
//  CircuitPlaygroundCompiler
//
//  Created by Nicolas Nascimento on 26/02/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

// This source code is based on
// https://harlanhaskins.com/2017/01/08/building-a-compiler-with-swift-in-llvm-part-1-introduction-and-the-lexer.html
//

// Indicates an element that can serve as a token type
protocol TokenType {
    
    // The string representation associated with the Token
    var stringValue: String { get }
    
    // The number of tokens a token holds.
    // This value will usually be 1 but more complex tokens may have more than 1 token
    var numberOfTokens: Int { get }
}

// Indicates an element that can perform and operation
protocol Operator: TokenType {
    var numberOfOperators: Int { get }
}

extension Operator {
    var numberOfOperators: Int {
        return 2
    }
}

// MARK: - Operators
enum Logic: String, Operator {
    case and = "and"
    case or = "or"
    case nand = "nand"
    case nor = "nor"
    case xor = "xor"
    case xnor = "xnor"
    case not = "not"
    
    var numberOfOperators: Int { return self == .not ? 1 : 2 }
}


enum Shift: String, Operator {
    case shiftLeftLogic = "sll"
    case shiftRightLogic = "srl"
    case shiftLeftArithmetic = "sla"
    case shiftRightArithmetic = "sra"
    case rotateLeft = "rol"
    case rotateRight = "ror"
}

enum Relational: String, Operator {
    case equal = "="
    case different = "/="
    case less = "<"
    case greater = ">"
}

enum Assignment: String, Operator {
    case signal = "<="
    case variable = ":="
}

enum Miscelaneous: String, Operator {
    case concatenation = "&"
}

enum Math: String, Operator {
    case plus = "+"
    case minus = "-"
    case times = "*"
    case divide = "/"
}

extension TokenType where Self: RawRepresentable, Self.RawValue == String {
    var stringValue: String {
        return self.rawValue
    }
    var numberOfTokens: Int {
        return 1
    }
}

enum Ponctuation: String, TokenType {
    case colon = ":"
    case semicolon = ";"
    case apostrophe = "'"
    case dot = "."
    case comma = ","
}

enum Keyword: String, TokenType {
    case library = "library"
    case use = "use"
    case `if` = "if"
    case then = "then"
    case `else` = "else"
    case entity = "entity"
    case port = "port"
    case `in` = "in"
    case out = "out"
    case of = "of"
    case `is` = "is"
    case architecture = "architecture"
    case begin = "begin"
    case end = "end"
    case when = "when"
    case signal = "signal"
    case process = "process"
}

enum FileCheckPoint {
    case eof
}

extension FileCheckPoint: TokenType {
    var stringValue: String { return "\0" }
    var numberOfTokens: Int { return 1 }
}

enum ComposedElement {
    case identifier(String)
    case number(Double)
    case `operator`(Operator)
    case multipleTokens([Token])
}

extension ComposedElement: TokenType {
    
    var stringValue: String {
        switch self {
        case .identifier(let value): return value
        case .multipleTokens(let multipleTokens): return multipleTokens.map{ String(describing: $0) }.joined()
        case .number(let value): return String(value)
        case .operator(let operation): return operation.stringValue
        }
    }
    
    var numberOfTokens: Int {
        switch self {
        case .multipleTokens(let tokens): return tokens.reduce(0, { $0 + $1.type.numberOfTokens })
        default: return 1
        }
    }
}

enum PrecedenceOperator: String, TokenType {
    case leftParenthesis = "("
    case rightParenthesis = ")"
}

struct Token {
    var type: TokenType
}


