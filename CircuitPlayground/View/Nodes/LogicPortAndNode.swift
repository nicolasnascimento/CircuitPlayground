//
//  LogicPortAndNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class LogicPortAndNode: SKSpriteNode {
    
}

extension LogicPortAndNode: LogicPortDrawer {
    func draw(with operation: LogicDescriptor.LogicOperation, in size: CGSize) {
        
        switch operation {
        case .and:
            
        case .or:s
            
        case .none:
            
        }
        
    }
}
