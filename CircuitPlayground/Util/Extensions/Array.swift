//
//  Array.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 25/05/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    func removingDuplicates() -> [Element] {
        return Array(Set<Element>(self))
    }
}
