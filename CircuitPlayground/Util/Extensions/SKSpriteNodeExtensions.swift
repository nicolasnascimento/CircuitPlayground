//
//  SKSpriteNodeExtensions.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

protocol Resizable {
    
    var resizeAnimationDuration: TimeInterval { get }
    var resizeKey: String { get }
    
    func resize(toFitHeight height: CGFloat, propagatesChange: Bool, animated: Bool)
    func resize(toFitWidth width: CGFloat, propagatesChange: Bool, animated: Bool)
    func resize(toFitSize newSize: CGSize, propagatesChange: Bool, animated: Bool)
}

extension Resizable {
    var resizeAnimationDuration: TimeInterval {
        return 1.0
    }
    var resizeKey: String {
        return "resizeKey"
    }
}

extension Resizable where Self == SKSpriteNode {
    /// This will call resizeToFitSize mainting image aspectRatio
    func resize(toFitHeight height: CGFloat, propagatesChange: Bool = false, animated: Bool = false) {
        if( self.size.height == 0 ) {
            print("cannot resize self = \(self), it has a zero height")
            return
        }else if( self.size.height == height) {
            print("\(self) already fits the specified height of \(height)")
            return
        }
        let aspectRatio = self.size.width/self.size.height
        let newSize = CGSize(width: height * aspectRatio, height: height)
        self.resize(toFitSize: newSize, propagatesChange: propagatesChange, animated: animated)
    }
    
    /// This will call resizeToFitSize mainting image aspectRatio
    func resize(toFitWidth width: CGFloat, propagatesChange: Bool = false, animated: Bool = false) {
        if( self.size.width == 0 ) {
            print("cannot resize self = \(self), it has a zero width")
            return
        }else if( self.size.width == width ) {
            print("\(self) already fits the specified width of \(width)")
            return
        }
        let aspectRatio = self.size.height/self.size.width
        let newSize = CGSize(width: width, height: width*aspectRatio)
        self.resize(toFitSize: newSize, propagatesChange: propagatesChange, animated: animated)
    }
}

extension SKSpriteNode: Resizable {
    
    func resize(toFitSize newSize: CGSize, propagatesChange: Bool = false, animated: Bool = false) {
        let normalizedSize = CGSize(width: newSize.width/self.xScale, height: newSize.height/self.yScale)
        
        // Propagates size changing
        if( propagatesChange ) {
            for c in self.children where c is SKSpriteNode {
                let spriteNode = c as! SKSpriteNode
                let newWidth = (spriteNode.size.width/self.size.width)*normalizedSize.width
                spriteNode.resize(toFitWidth: newWidth, propagatesChange: propagatesChange)
            }
        }
        
        if( animated ) {
            let duration = animated ? self.resizeAnimationDuration : 0.0
            let resizingAction = SKAction.resize(toWidth: normalizedSize.width, height:normalizedSize.height, duration: duration)
            self.run(resizingAction, withKey: self.resizeKey)
        } else {
            self.size = normalizedSize
        }
    }
}
