//
//  CanvasNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 20/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

final class CanvasNode: SKSpriteNode {
    
    /// The default background color for the Canvas Node
    static let defaultBackgroundColor: SKColor = .lightGray
    
    // MARK: - Initialization
    init(in size: CGSize, color: SKColor = CanvasNode.defaultBackgroundColor) {
        
        // Call super using appropriate parmeters
        super.init(texture: nil, color: color, size: size)
        
        if Environment.debugMode {
//            self.createGrid()
        }
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension CanvasNode {
    private func createGrid() {
        
        for i in 0..<Int(GridComponent.maxDimension.x) {
            for j in 0..<Int(GridComponent.maxDimension.y) {
                let coordinate = Coordinate(x: i, y: j)
                let shapeNode = SKShapeNode(circleOfRadius: 2)
                self.addChild(shapeNode)
                shapeNode.fillColor = .black
                shapeNode.alpha = 0.2
                shapeNode.position = GridComponent.position(for: coordinate)//CGPoint(x: CGFloat(i)*GridComponent.maximumIndividualSize.width - (self.size.width - GridComponent.maximumIndividualSize.width)*0.5, y: CGFloat(j)*GridComponent.maximumIndividualSize.height - (self.size.height - GridComponent.maximumIndividualSize.height)*0.5)
                shapeNode.position.y -= self.size.height*0.5
                shapeNode.position.x -= self.size.width*0.5
            }
        }
        
    }
}
