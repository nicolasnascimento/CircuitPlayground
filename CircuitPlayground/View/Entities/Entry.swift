//
//  Entry.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class Entry: RenderableEntity {

    let signal: Signal
    
    init(at coordinate: Coordinate, signal: Signal) {
        self.signal = signal
        super.init(at: coordinate)
        
        let entryComponent = EntryComponent(signal: signal)
        self.addComponent(entryComponent)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Entry {
    override var description: String {
        return "Entry - signal:(\(self.signal)"
    }
}
