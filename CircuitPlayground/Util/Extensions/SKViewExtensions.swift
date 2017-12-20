//
//  SKViewExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 20/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

// MARK: - SKView Forwarding Mouse Scroll Event
extension SKView {
    open override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        self.scene?.scrollWheel(with: event)
    }
}

