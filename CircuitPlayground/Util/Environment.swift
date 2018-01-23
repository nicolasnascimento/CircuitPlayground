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
        #if iOS
            return true
        #else
            return false
        #endif
    }
}

// MARK: - Images
extension Environment {
    enum Images {
        static let andPortImageName:    String = "LogicAndPort"
        static let orPortImageName:     String = "LogicOrPort"
        static let nonePortImageName:   String = "LogicNonePort"
        static let notPortImageName:    String = "LogicNotPort"
        
        static func image(for operation: LogicDescriptor.LogicOperation) -> String {
            switch operation {
            case .none: return Environment.Images.nonePortImageName
            case .or:   return Environment.Images.orPortImageName
            case .and:  return Environment.Images.andPortImageName
            case .not:  return Environment.Images.notPortImageName
            }
        }
    }
}

extension Environment {
    enum JSONFiles {
        static let baseFileName:    String = "base"
    }
}


