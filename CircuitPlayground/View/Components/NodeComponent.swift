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

extension NodeComponent : RenderableComponent {
    
}
