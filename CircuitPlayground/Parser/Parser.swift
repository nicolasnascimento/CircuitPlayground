//
//  Parser.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

class Parser {
    
    var fileName: String
    
    init(fileNamed fileName: String) {
        self.fileName = fileName
    }
    
    // MARK: - Public
    func parseCurrentFile() {
        
        guard let url = Bundle.main.url(forResource: self.fileName, withExtension: "json") else {  fatalError("Invalid File url") }
        do {
            let file = try Data.init(contentsOf: url)
            do {
                let specification = try JSONDecoder().decode(LogicSpecification.self, from: file)
                print(specification)
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        print("TODO")
        print(#function)
    }
    // MARK: - Private
    
}
