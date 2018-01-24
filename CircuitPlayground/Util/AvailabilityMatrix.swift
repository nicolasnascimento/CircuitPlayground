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
    private var spots: [[Bool]]
    
    
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
                self.spots[row].append(false)
            }
        }
    }
    
    // MARK: - Public
    func at(row: Int, column: Int) -> Bool {
        if( self.valid(row: row, column: column) ) {
            return self.spots[row][column]
        }
        return false
    }
    mutating func set(row: Int, column: Int) {
        if( self.valid(row: row, column: column) ) {
            self.spots[row][column] = true
        }
    }
    mutating func untake(row: Int, column: Int) {
        if( self.valid(row: row, column: column) ) {
            self.spots[row][column] = false
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

