//
//  Entry.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class EntryPin: RenderableEntity, Pin {

    // MARK: - Public
    let signal: Signal
 
    required init(signal: Signal) {
        self.signal = signal
        super.init(at: .zero)

        let entryComponent = PinComponent(signal: signal, type: .entry)
        self.addComponent(entryComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

