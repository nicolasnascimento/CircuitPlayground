//
//  NSColorExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 25/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import AppKit.NSColor

extension NSColor {
    
    static var random: NSColor {
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
