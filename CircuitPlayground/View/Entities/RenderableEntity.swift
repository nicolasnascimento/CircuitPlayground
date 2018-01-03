//
//  RenderableEntity.swift
//  ProjectTaurus
//
//  Created by Nicolas Nascimento on 07/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class RenderableEntity: GKEntity {
    
    // MARK: - Public Properties
    var nodeComponent: NodeComponent {
        return self.component(ofType: NodeComponent.self)!
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        let component = NodeComponent(node: SKNode())
        self.addComponent(component)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override
    
    override func addComponent(_ component: GKComponent) {
        super.addComponent(component)
        
        // Add node to root
        if let node = (component as? RenderableComponent)?.node, node != nodeComponent.node {
            self.nodeComponent.node.addChild(node)
        }
    }
    
    override func __removeComponent(for componentClass: Swift.AnyClass) {
        
        // Remove node from parent
        if let node = (self.component(ofType: componentClass as! GKComponent.Type) as? RenderableComponent)?.node {
            node.removeFromParent()
        }
        
        super.__removeComponent(for: componentClass)
    }
}
