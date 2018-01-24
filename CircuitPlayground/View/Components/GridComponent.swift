//
//  GridComponent.swift
//  ProjectTaurus
//
//  Created by Nicolas Nascimento on 11/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

struct Coordinate: Decodable {
    var x: Int
    var y: Int
    
    // A coordinated centered in the origin
    static let zero: Coordinate = Coordinate(x: 0, y: 0)
}

extension Coordinate: Equatable {
    static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
}

class GridComponent: GKComponent {
    
    static let gridDimensions: CGSize = Environment.Dimensions.size
    
    // MARK: - Static
    static let maxDimension = CGPoint(x: 11, y: 22)
    static var maximumIndividualSize: CGSize {
        let size = GridComponent.gridDimensions
        let minimumHeight = size.height/GridComponent.maxDimension.y
        let minimumWidth = size.width/GridComponent.maxDimension.x
        return CGSize(width: minimumWidth, height: minimumHeight)
    }
    
    class func position(for coordinate: Coordinate) -> CGPoint {
        
        let size = GridComponent.gridDimensions
        let minimumHeight = size.height/GridComponent.maxDimension.y
        let minimumWidth = size.width/GridComponent.maxDimension.x
        
        return CGPoint(x: minimumWidth*CGFloat(coordinate.x), y: minimumHeight*CGFloat(coordinate.y))
    }
    
    // MARK: - Public Properties
    var coordinate: Coordinate
    
    var cgPoint: CGPoint {
        return GridComponent.position(for: self.coordinate)
    }
    
    // MARK: - Public
    init(with coordinate: Coordinate) {
        self.coordinate = coordinate
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
