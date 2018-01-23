//
//  LogicPortNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

// A node that encapsulates the drawing of a logic port
class LogicPortNode: SKSpriteNode {
    var operation: LogicDescriptor.LogicOperation = .none {
        didSet {
            self.draw()
        }
    }
    
    // MARK: - Initialization
    init(operation: LogicDescriptor.LogicOperation) {
        let texture = SKTexture(imageNamed: Environment.Images.image(for: operation))
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogicPortNode: LogicPortDrawable {
    
    /// Sets operation and size of SpriteNode. Calls draw() afterwards
    func draw(with operation: LogicDescriptor.LogicOperation, in size: CGSize) {
        // No matter what we do, always redraw at the end
        defer {
            self.draw()
        }
        
        // Set drawing parameters
        self.operation = operation
        self.size = size
    }
    
    func draw() {
        let texture = SKTexture(imageNamed: Environment.Images.image(for: self.operation))
        self.run(SKAction.setTexture(texture))
    }
}
