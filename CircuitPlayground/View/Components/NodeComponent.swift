//
//  NodeComponent.swift
//  ProjectTaurus
//
//  Created by Nicolas Nascimento on 07/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

protocol RenderableComponent {
    var node: SKNode { get }
}

typealias NodeComponent = GKSKNodeComponent

protocol Anchorable {
    var anchorPoint: CGPoint { get }
    var size: CGSize { get }
}

extension SKSpriteNode: Anchorable {}
extension SKScene: Anchorable {}

extension NodeComponent {
    var position: CGPoint {
        get { return self.node.position }
        set {
            self.node.position = newValue
            
            if let anchorable = self.node.parent as? Anchorable {
                node.position.x -= anchorable.size.width*anchorable.anchorPoint.x
                node.position.y -= anchorable.size.height*anchorable.anchorPoint.y
            }
            
        }
    }
}

extension NodeComponent : RenderableComponent {

}
