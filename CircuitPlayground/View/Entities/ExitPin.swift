//
//  ExitPoint.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 24/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class ExitPin: RenderableEntity, Pin {

    // MARK: - Public
    let signal: Signal
    
    required init(signal: Signal) {
        self.signal = signal
        super.init(at: .zero)
        
        let entryComponent = PinComponent(signal: signal)
        self.addComponent(entryComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
