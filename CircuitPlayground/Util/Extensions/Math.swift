//
//  Math.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 07/06/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import Foundation
import simd

// General Purpose

extension Int  {
    static func *<T>(lhs: Int, rhs: T) -> T where T: FloatingPoint {
        return type(of: rhs).init(lhs)*rhs
    }
    static func ==<T>(lhs: Int, rhs: T) -> Bool where T: FloatingPoint {
        return type(of: rhs).init(lhs) == rhs
    }
}

extension Double {
    static func *<T>(lhs: Double, rhs: T) -> T where T: SignedInteger {
        return type(of: rhs).init(lhs)*rhs
    }
    static func ==<T>(lhs: Double, rhs: T) -> Bool where T: SignedInteger {
        return type(of: rhs).init(lhs) == rhs
    }
    
    static func <=(lhs: Double, rhs: Float) -> Bool {
        return lhs <= Double(rhs)
    }
}

extension vector_int2: Hashable {
    public var hashValue: Int {
        return 84234*self.x.hashValue + 34563*self.y.hashValue
    }
}


// 2D Points
protocol Point {
    var doubleX: Double { get }
    var doubleY: Double { get }
    
    func distance(to other: Point) -> Double
}

extension Point {
    func distance(to other: Point) -> Double {
        let deltaX = self.doubleX - other.doubleX
        let deltaY = self.doubleY - other.doubleY
        return sqrt(deltaX*deltaX + deltaY*deltaY)
    }
}


extension vector_float2: Point {
    var doubleX: Double { return Double(self.x) }
    var doubleY: Double { return Double(self.y) }
}

extension vector_int2: Point {
    var doubleX: Double { return Double(self.x) }
    var doubleY: Double { return Double(self.y) }
}



//func distance<T>(from to other: T) -> Double {
//    let deltaX = self.x - other.x
//    let deltaY = self.y - other.y
//    return sqrt(deltaX*deltaX + deltaY*deltaY)
//}
