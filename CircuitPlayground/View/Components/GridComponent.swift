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
}

class GridComponent: GKComponent {
    
    // MARK: - Static
    static let maxDimension = CGPoint(x: 11, y: 22)
    static var maximumIndividualSize: CGSize {
        let size = NSScreen.main!.visibleFrame.size
        let minimumHeight = size.height/GridComponent.maxDimension.y
        let minimumWidth = size.width/GridComponent.maxDimension.x
        return CGSize(width: minimumWidth, height: minimumHeight)
    }
    
    class func position(for coordinate: Coordinate) -> CGPoint {
        
        let size = NSScreen.main!.visibleFrame.size
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
