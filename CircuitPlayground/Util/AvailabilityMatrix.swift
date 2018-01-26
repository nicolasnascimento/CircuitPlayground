//
//  AvailabilityMatrix.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 24/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

struct AvailabilityMatrix {
    
    // MARK: - Public
    let height: Int
    let width: Int
    
    // MARK: - Private
    var spots: [[RenderableEntity?]]
    
    
    // MARK: - Inititalization
    init(width: Int, height: Int) {
        self.spots = []
        
        self.width = width
        self.height = height
        // Lines
        for row in 0..<height {
            self.spots.append([])
            // Columns
            for _ in 0..<Int(width) {
                self.spots[row].append(nil)
            }
        }
    }
    
    // MARK: - Public
    func at(row: Int, column: Int) -> RenderableEntity? {
        if( self.valid(row: row, column: column) ) {
            return self.spots[row][column]
        }
        return nil
    }
    mutating func set(value: RenderableEntity?,row: Int, column: Int) {
        if( self.valid(row: row, column: column) ) {
            self.spots[row][column] = value
        }
    }
    mutating func untake(row: Int, column: Int) {
        if( self.valid(row: row, column: column) ) {
            self.spots[row][column] = nil
        }
    }
    private func valid(row: Int, column: Int) -> Bool {
        if( row >= 0 && row < self.spots.count ) {
            let line = self.spots[row]
            if( column >= 0 && column < line.count ) {
                return true
            }
        }
        return false
    }
}

extension AvailabilityMatrix: CustomDebugStringConvertible {
    var debugDescription: String {
        var description = ""
        description += "[" + "\n"
        for line in self.spots {
            description += line.description + "\n"
        }
        description += "]" + "\n"
        return description
    }
}

