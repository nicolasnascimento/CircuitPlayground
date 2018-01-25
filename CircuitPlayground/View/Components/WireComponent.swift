//
//  WireComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class WireComponent: GKComponent {
    
    var wireNode: WireNode
    var path: [Coordinate] = []
    
    init(source: Coordinate, destination: Coordinate, availabilityMatrix: AvailabilityMatrix) {
        
        // The graph which will be used for
        let graph = GKGraph([])
        
        var sourceNode: GKGraphNode2D!
        var destinationNode: GKGraphNode2D!
        
        // Create nodes
        for row in 0..<availabilityMatrix.height {
            for column in 0..<availabilityMatrix.width {
                let node = GKGraphNode2D()
                node.position.x = Float(column)
                node.position.y = Float(row)
                if( row == source.y && column == source.x ) {
                    sourceNode = node
                } else if( row == destination.y && column == destination.x ) {
                    destinationNode = node
                }
                
                graph.add([node])
            }
        }
        
        // Create edges
        for node in graph.nodes ?? [] {
            guard let node2D = node as? GKGraphNode2D else { continue }
            
            // Connect all edges of node
            let pointsToConnect: Set<vector_float2> = [
                vector_float2(node2D.position.x - 1, node2D.position.y - 1),
                vector_float2(node2D.position.x + 0, node2D.position.y - 1),
                vector_float2(node2D.position.x + 1, node2D.position.y - 1),
                vector_float2(node2D.position.x - 1, node2D.position.y),
                vector_float2(node2D.position.x + 1, node2D.position.y),
                vector_float2(node2D.position.x - 1, node2D.position.y + 1),
                vector_float2(node2D.position.x + 0, node2D.position.y + 1),
                vector_float2(node2D.position.x + 1, node2D.position.y + 1),
            ]
            
            // [Point] -> [Node]
            var nodesToConnect: [GKGraphNode2D] = []
            
            for aNode in graph.nodes ?? [] {
                if let aNode2D = aNode as? GKGraphNode2D {
                    let position = aNode2D.position
                    if let _ = pointsToConnect.index(of: position) {
                        nodesToConnect.append(aNode2D)
                    }
                }
            }
            
            // Create Edges
            
            let nonConnectedNodes = nodesToConnect.filter{ !$0.connectedNodes.contains(node2D) }
            
            node2D.addConnections(to: nonConnectedNodes, bidirectional: true)
        }
        
        guard let path = graph.findPath(from: sourceNode, to: destinationNode) as? [GKGraphNode2D] else { fatalError("GKGraphNode2D should be used here") }
        
        let points: [CGPoint] = path.map{
            let coordinate = Coordinate(x: Int($0.position.x), y: Int($0.position.y))
            return GridComponent.position(for: coordinate)
            
        }
        self.path = points.map{ Coordinate(x: Int($0.x), y: Int($0.y)) }
        
        self.wireNode = WireNode(points: points)
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WireComponent: RenderableComponent {
    var node: SKNode {
        return self.wireNode
    }
}

extension vector_float2: Hashable {
    public var hashValue: Int {
        return self.x.hashValue + self.y.hashValue
    }
}
