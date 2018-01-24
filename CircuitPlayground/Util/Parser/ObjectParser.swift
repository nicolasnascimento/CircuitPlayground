//
//  ObjectParser.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

class ObjectParser {
    
    // MARK: - Specifialed Error Definitions
    enum ParsingError: String, Error {
        case invalidUrl
        
        var localizedDescription: String {
            return self.rawValue
        }
    }
    
    // MARK: - Public
    class func parse(fileNamed fileName: String, completionHandler handler: @escaping (_ specification: LogicSpecification?,_ error: Error?) -> Void)  {
        if let url = Bundle.main.url(forResource: fileName, withExtension: Environment.Files.JSON.extension) {
            do {
                let file = try Data.init(contentsOf: url)
                do {
                    let specification = try JSONDecoder().decode(LogicSpecification.self, from: file)
                    handler(specification, nil)
                } catch {
                    handler(nil, error)
                }
            } catch {
                handler(nil, error)
            }
        } else {
            handler(nil, ParsingError.invalidUrl)
        }
    }
    // MARK: - Private
}
