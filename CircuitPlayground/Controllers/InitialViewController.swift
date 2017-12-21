//
//  InitialViewController.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Cocoa
import SpriteKit

class InitialViewController: NSViewController {

    @IBOutlet private var editorTextView: NSTextView!
    @IBOutlet private weak var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.initialize()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        self.handleViewSizeUpdate()
    }
    
    // MARK: - Private
    private func handleViewSizeUpdate() {
        if let scene = self.skView.scene {
            scene.size = CGSize(width: self.view.frame.width*0.5, height: self.view.frame.height)
        } else {
            self.setupSKView()
            self.setupScene()
        }
    }
    
    private func initialize() {
        
        // Set Editor View
        self.setupEditorTextView()
        
        // Set SpriteKit View
        self.setupSKView()
        
        // TEMPORARY - Read file containing specs of circuit
        self.readBaseFile()
    }
    
}

extension InitialViewController: NSTextViewDelegate {
    
    private func setupEditorTextView() {
        
        // Set Delegate
        self.editorTextView.delegate = self
    }
    
    // MARK: - Text View Delegate
}

extension InitialViewController: SKViewDelegate {
    
    private func setupSKView() {
        // Set SKView
        self.skView.delegate = self
    }
    fileprivate func setupScene() {
        // Instatiante the Scene using the bounds from the view
        let side = 1024.0 as CGFloat
        let scene = CircuitScene(size: CGSize(side: side))
        
        // Here, we'll be using aspectFill because all drawing will happen inside a `drawable` node, not directly to the scene.
        // This will display the SKView if the user decides to pinch to zoom
        scene.scaleMode = .aspectFill
        
        // Present scene
        self.skView.presentScene(scene)
    }
    
    // MARK: - SKView Delegate
    func view(_ view: SKView, shouldRenderAtTime time: TimeInterval) -> Bool {
        return true
    }
}

extension InitialViewController {
    
    func readBaseFile() {

        ObjectParser.parse(fileNamed: Environment.JSONFiles.baseFileName) { (specification, error) in
            if let error = error {
                print(error)
            } else if let specification = specification {
                
                
            }
        }
        
    }
}
