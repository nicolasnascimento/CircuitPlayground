//
//  CircuitScene.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 08/12/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import SpriteKit

class CircuitScene: SKScene {
    
    // MARK: - Public Properties
    let aspectRatio = 16.0/9.0
    let defaultBackgroundColor: SKColor = .darkGray
    
    // MARK: - Private
    var previousScale: CGFloat = 1.0
    var handlingMomentum: Bool = false
    
    // MARK: - SKScene life cycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Perform Additional Setup
        self.initialize()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        self.canvasNode?.center()
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // Remove Gesture Recognizers
        self.removeGestureRecognizers()
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func initialize() {
        
        // Perform scene setup
        self.backgroundColor = self.defaultBackgroundColor
        
        // Initialize canvas
        self.setCanvasNode()
        
        // Set Gesture Recognizer
        self.setGestureRecognizers()
    }
}


extension CircuitScene {
    
    /// The node where all drawing is performed
    private var canvasNodeName: String { return "CanvasNode" }
    var canvasNode: CanvasNode? {
        get { return self.childNode(withName: canvasNodeName) as? CanvasNode }
        set {
            if let newCanvasNode = newValue {
                if( self.canvasNode != newCanvasNode ) {
                    self.canvasNode?.removeFromParent()
                    newCanvasNode.name = self.canvasNodeName
                    self.addChildNode(newCanvasNode)
                }
            } else {
                self.canvasNode?.removeFromParent()
            }
        }
    }

    private func setCanvasNode() {
        
        // Calculate size respecting aspect ratio
        let width = 853.3
        let height = 480.0//self.size.height/*width*(1.0/self.aspectRatio)*/
        let canvasSize = CGSize(width: width, height: height)
        
        // Create node and set properties
        let node = CanvasNode(in: canvasSize)
        node.name = self.canvasNodeName
        
        // Add node and center
        self.addChildNode(node)
        node.center()
    }
}

extension CircuitScene {
    
    func setGestureRecognizers() {
        let pinchRecognizer = NSMagnificationGestureRecognizer(target: self, action: #selector(self.handleMagnification(for:)))
        self.view?.addGestureRecognizer(pinchRecognizer)
    }
    
    func removeGestureRecognizers() {
        for recognizer in self.view?.gestureRecognizers ?? [] {
            self.view?.removeGestureRecognizer(recognizer)
        }
    }
    
    override func scrollWheel(with event: NSEvent) {
        super.scrollWheel(with: event)
        guard let canvasNode = self.canvasNode else { return }
        
        // Set correct canvas node position
        canvasNode.position.x += event.deltaX
        canvasNode.position.y -= event.deltaY
        
        if( self.handlingMomentum ) {
            switch event.momentumPhase {
            case .ended:
                self.handlingMomentum = false
                canvasNode.center()
            default:
                break
            }
        }
        
        
        // If we're in the ended phase, perform correcting action if needed
        if( event.phase == .ended ) {
        
            let nextEvent = NSApp.nextEvent(matching: .scrollWheel, until: Date.init(timeIntervalSinceNow: 1.0/60.0), inMode: .defaultRunLoopMode, dequeue: false)
            if let next = nextEvent {
                if( next.momentumPhase != .began ) {
                    self.handlingMomentum = false
                    canvasNode.center()
                } else {
                    self.handlingMomentum = true
                }
            } else {
                self.handlingMomentum = false
                canvasNode.center()
            }
        }
    }
    
    @objc func handleMagnification(for gesture: NSGestureRecognizer) {
        guard let magnification = (gesture as? NSMagnificationGestureRecognizer)?.magnification else { return }
        switch gesture.state {
        case .ended:
            let delta = previousScale + magnification
            self.canvasNode?.setScale(delta)
            self.previousScale = delta
        case .changed:
            let delta = previousScale + magnification
            self.canvasNode?.setScale(delta)
        default:
            return
        }
    }
}
