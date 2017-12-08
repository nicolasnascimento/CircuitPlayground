//
//  LogicPortDrawer.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

protocol LogicPortDrawer: class {
    /// This should draw the appropriate port based in the operation
    func draw(with operation: LogicDescriptor.LogicOperation, in size: CGSize)
}
