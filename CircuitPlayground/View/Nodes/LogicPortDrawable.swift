//
//  LogicPortDrawable.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

protocol Drawable: class {
    /// The bounds in which to draw
    var size: CGSize { get set }
    
    /// This should use the parameters above to create a visual representation
    func draw()
}

// A protocol which defines the minimum drawing capability
protocol LogicPortDrawable: Drawable {
    
    /// The operation to be represented
    var operation: LogicDescriptor.LogicOperation { get set }
}
