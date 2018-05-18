//
//  InitialViewController.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 30/11/17.
//  Copyright © 2017 Nicolas Nascimento. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class InitialViewController: NSViewController {

    // MARK: - Outlets
    @IBOutlet private weak var skView: SKView!
    
    // MARK: - Properties
    var entityManager: EntityManager!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.initialize()
        
        let fileName = "when-else-single"
        let specification = self.generateSpecification(readingFrom: fileName)
        
        let circuitDescription = CircuitDescription(singleCircuitSpecification: specification)
        print(circuitDescription)
        // Populate entities from circuit description
        self.entityManager.populate(with: circuitDescription)
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
        
        // Set Entity Manager
        self.setupEntityManager()
    }
}

extension InitialViewController: NSTextViewDelegate {
    
    private func setupEditorTextView() {
        
        // Set Delegate
//        self.editorTextView.delegate = self
    }
}

extension InitialViewController: SKViewDelegate {
    
    private func setupSKView() {
        // Set SKView
        self.skView.delegate = self
        
        // Set Debug Mode
        if( Environment.debugMode ) {
            self.skView.showsFPS = true
            self.skView.showsNodeCount = true
        }
        
        // Perform Initial Setup Scene
        self.setupScene()
    }
    fileprivate func setupScene() {
        // Instatiante the Scene using the bounds from the view
        let size = Environment.Dimensions.size
        let scene = CircuitScene(size: size)
        
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
    
    func read(fileNamed fileName: String, with completion: @escaping (_ specification: LogicSpecification?, _ error: Error?) -> Void) {
        
        ObjectParser.parse(fileNamed: fileName) { (specification, error) in
            if let error = error {
                completion(nil, error)
            } else if let specification = specification {
                completion(specification, nil)
            }
        }
    }
    
    func generateSpecification(readingFrom fileName: String) -> LogicSpecification {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "vhd") else { fatalError("Couldn't From url from path \(fileName)") }
        
        print(url)
        guard let data = try? Data.init(contentsOf: url) else { fatalError("Couldn't extract data from path \(url)") }
        guard let textFromFile = String(data: data, encoding: .utf8) else { fatalError("Couldn't Extract Text From File") }
        var lexer = Lexer(input: textFromFile)
        let tokens = lexer.lex()
    
        var parser = Parser(tokens: tokens)
        
        do {
            let expressions = try parser.parseFile()
            
            var synthesisPerformer = SynthesisPerformer(expressions: expressions)
            return synthesisPerformer.extractLogicSpecification()
        } catch {
            guard let parsingError = error as? ParserError else { fatalError("Couldn't Extract Expressions from parser") }
            switch parsingError {
            case .unknown(let description):
                fatalError("Couldn't Extract Expressions from parser, description: \(description)")
            }
        }
    }
}

extension InitialViewController: EntityManagerDelegate {
    
    func setupEntityManager() {
        
        self.entityManager = EntityManager()
        self.entityManager.delegate = self
    }
    
    // MARK: - Entity Manager Delegate
    func entityManager(_ entityManager: EntityManager, didAdd entity: GKEntity) {
        if let node = (entity as? RenderableEntity)?.nodeComponent.node {
            (self.skView.scene as? CircuitScene)?.canvasNode?.addChildNode(node)
        }
    }
    func entityManager(_ entityManager: EntityManager, didRemove entity: GKEntity) {
        if let node = (entity as? RenderableEntity)?.nodeComponent.node {
            node.removeFromParent()
        }
    }
    func entityManager(_ entityManager: EntityManager, didFailToRemove entity: GKEntity) {
        fatalError("Attemping to Remove Entity '\(entity)' Failed")
    }
}
