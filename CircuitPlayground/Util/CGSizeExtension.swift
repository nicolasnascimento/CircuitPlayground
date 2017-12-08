//
//  CGSizeExtension.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation

extension CGSize {
    
    // MARK: - Convenience initialization for creating a square
    init(side: CGFloat) {
        self.init(width: side, height: side)
    }
}

