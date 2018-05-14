//
//  Environment.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

/// A class that handles multiple environment settings and configuration
enum Environment {
    
    // This tells wheter the app is runnnig in debug mode
    static var debugMode: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}

// MARK: - Images
extension Environment {
    enum Images {
        static let andPortImageName:    String = "And-Gate"
        static let orPortImageName:     String = "Or-Gate"
        static let nonePortImageName:   String = "Connection-Gate"
        static let notPortImageName:    String = "LogicNotPort"
        static let nandPortImageName:   String = "Nand-Gate"
        static let norPortImageName:    String = "Nor-Gate"
        static let xorPortImageName:    String = "Xor-Gate"
        static let pinImageName:        String = "Pin"
        
        static func image(for operation: LogicDescriptor.LogicOperation) -> String {
            switch operation {
            case .none: return Environment.Images.nonePortImageName
            case .or:   return Environment.Images.orPortImageName
            case .and:  return Environment.Images.andPortImageName
            case .not:  return Environment.Images.notPortImageName
            case .nand: return Environment.Images.nandPortImageName
            case .nor: return Environment.Images.norPortImageName
            case .xor: return Environment.Images.xorPortImageName
            }
        }
    }
}

// MARK: - Files
extension Environment {
    enum Files {
        enum JSON {
            static let `extension`: String = "json"
            static let baseFile:    String = "base"
        }
    }
}

extension Environment {
    enum Dimensions {
        static let size: CGSize = CGSize(side: 1024)
    }
}

extension Environment {
    enum Text {
        static let fontName = "Multicolore"
        static let fontSize = CGFloat(12.0)
    }
}


