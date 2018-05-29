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
            self.createGrid()
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
                let shapeNode = SKShapeNode(rectOf: GridComponent.maximumIndividualSize)
                self.addChild(shapeNode)
                shapeNode.fillColor = .clear
                shapeNode.strokeColor = .black
                shapeNode.alpha = 0.1
                shapeNode.position = CGPoint(x: CGFloat(i)*GridComponent.maximumIndividualSize.width - (self.size.width - GridComponent.maximumIndividualSize.width)*0.5, y: CGFloat(j)*GridComponent.maximumIndividualSize.height - (self.size.height - GridComponent.maximumIndividualSize.height)*0.5)
            }
        }
        
    }
}
