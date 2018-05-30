//
//  GridComponent.swift
//  ProjectTaurus
//
//  Created by Nicolas Nascimento on 11/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

struct Coordinate: Codable, Equatable {
    var x: Int
    var y: Int
    
    // A coordinated centered in the origin
    static let zero: Coordinate = Coordinate(x: 0, y: 0)
}

class GridComponent: GKComponent {
    
    enum UsageType {
        case input
        case output
        case undefined
    }
    
    static let gridDimensions: CGSize = Environment.Dimensions.size
    
    // MARK: - Static
    static let maxDimension = CGPoint(x: 18, y: 18)
    static var maximumIndividualSize: CGSize {
        let size = GridComponent.gridDimensions
        let minimumHeight = size.height/GridComponent.maxDimension.y
        let minimumWidth = size.width/GridComponent.maxDimension.x
        return CGSize(width: minimumWidth, height: minimumHeight)
    }
    
    class func position(for coordinate: Coordinate) -> CGPoint {
//
//        let size = GridComponent.gridDimensions
//        let minimumHeight = size.height/GridComponent.maxDimension.y
//        let minimumWidth = size.width/GridComponent.maxDimension.x
        return CGPoint(x: GridComponent.maximumIndividualSize.width*CGFloat(coordinate.x), y: GridComponent.maximumIndividualSize.height*CGFloat(coordinate.y))
    }
    
    // MARK: - Public Properties
    private var coordinates: [Coordinate]
    
    private var height: Int
    private var width: Int
    
    var firstCGPoint: CGPoint? {
        guard let firstCoordinate = self.coordinates.first else { return nil }
        return GridComponent.position(for: firstCoordinate)
    }
    var firstCoordinate: Coordinate? {
        return self.coordinates.first
    }
    
    // MARK: - Public
    convenience init(withSingle coordinate: Coordinate) {
        self.init(with: [coordinate])
    }
    
    convenience init(withBottomLeft coordinate: Coordinate, height: Int, width: Int) {
        self.init(with: GridComponent.generateCoordinates(withBottomLeft: coordinate, height: height, width: width))
    }
    
    init(with coordinates: [Coordinate]) {
        self.coordinates = coordinates
        self.height = 1
        self.width = 1
        super.init()
        
        self.updateWidthAndHeight(for: coordinates)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(bottomLeft coordinate: Coordinate) {
        self.coordinates = GridComponent.generateCoordinates(withBottomLeft: coordinate, height: self.height, width: self.width)
    }
    
    func coordinates(for usage: UsageType) -> [Coordinate] {
        switch usage {
        case .input: return self.coordinates.sorted{ $0.x < $1.x }.sorted{ $0.y < $1.y }
        case .output: return self.coordinates.sorted{ $0.x > $1.x }.sorted{ $0.y > $1.y }
        case .undefined: return self.coordinates
        }
    }
}

// MARK: - Private
extension GridComponent {
    private static func generateCoordinates(withBottomLeft coordinate: Coordinate, height: Int, width: Int) -> [Coordinate] {
        var coordinates = [coordinate]
        let additionalHeightCoordinates = Array(1..<height).map{ Coordinate(x: coordinate.x, y: coordinate.y + $0) }
        let additionalWidthCoordinates = Array(1..<width).map{ Coordinate(x: coordinate.x + $0, y: coordinate.y) }
        coordinates.append(contentsOf: additionalHeightCoordinates + additionalWidthCoordinates)
        
        return coordinates
    }
    
    private func updateWidthAndHeight(for coordinates: [Coordinate]) {
        // Update width and height
        if let controlCoordinate = coordinates.first {
            var iterator = controlCoordinate
            var maxWidth = 1
            var maxHeight = 1
            while let _ = coordinates.index(of: Coordinate(x: iterator.x + maxWidth, y: iterator.y)) { maxWidth += 1 }
            
            iterator = controlCoordinate
            while let _ = coordinates.index(of: Coordinate(x: iterator.x, y: iterator.y + maxHeight)) { maxHeight += 1 }
            
            self.height = maxHeight
            self.width = maxWidth
        }
    }
}
