//
//  LabelNode.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 25/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class LabelNode: SKLabelNode {
    
    override init() {
        super.init()
    }
    
    init(text: String) {
        
        super.init(fontNamed: nil)
        self.fontName = Environment.Text.fontName
        self.text = text
        self.fontSize = Environment.Text.fontSize
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
