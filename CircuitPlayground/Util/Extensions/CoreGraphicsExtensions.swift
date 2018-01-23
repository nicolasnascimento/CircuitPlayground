//
//  CoreGraphicsExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Foundation
import AppKit

extension CGSize {
    
    // MARK: - Convenience initialization for creating a square
    init(side: CGFloat) {
        self.init(width: side, height: side)
    }
}

// MARK: - CGFloat operations
extension CGFloat {
    
    static func *(lhs: CGFloat, rhs: Double) -> CGFloat {
        return lhs*CGFloat(rhs)
    }
}

extension Double {
    static func +=(lhs: inout Double, rhs: Int) {
        lhs = lhs + Double(rhs)
    }
    static func +(lhs: Double, rhs: Int) -> Double {
        return lhs + Double(rhs)
    }
    static func +(lhs: Int, rhs: Double) -> Double {
        return Double(lhs) + rhs
    }
}

public extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveToBezierPathElement: path.move(to: points[0])
            case .lineToBezierPathElement: path.addLine(to: points[0])
            case .curveToBezierPathElement: path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePathBezierPathElement: path.closeSubpath()
            }
        }
        return path
    }
    
}

