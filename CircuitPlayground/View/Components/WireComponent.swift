//
//  WireComponent.swift
//  CircuitPlayground
//
//  Created by Nicolas Nascimento on 23/01/18.
//  Copyright © 2018 Nicolas Nascimento. All rights reserved.
//

import GameplayKit

class WireComponent: GKComponent {
    
    var parentNode: SKNode
    
    var wireNode: WireNode!
    
    var path: [Coordinate] = []
    
    var source: Coordinate
    var destination: Coordinate
    
    init(source: Coordinate, destination: Coordinate) {
        self.source = source
        self.destination = destination
        self.parentNode = SKNode()
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func connect(avoiding availabilityMatrix: AvailabilityMatrix)  {
        
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
                let entityAtSpot = availabilityMatrix.at(row: row, column: column)
                if( !(entityAtSpot is Wire) ) {
                    graph.add([node])
                }
            }
        }
        
        
        guard let nodes2D = graph.nodes as? [GKGraphNode2D] else { fatalError("Only GKGraphNode2D should be used in this graph") }
        // Create edges
        for node2D in nodes2D {
            
            // Connect all edges of node
            // Change this. To support lack of nodes directly around
            let pointsToConnectArrayNullable = [
                nodes2D.closestNode(to: .north, from: node2D),
                nodes2D.closestNode(to: .south, from: node2D),
                nodes2D.closestNode(to: .west, from: node2D),
                nodes2D.closestNode(to: .east, from: node2D),
                nodes2D.closestNode(to: .northeast, from: node2D),
                nodes2D.closestNode(to: .northwest, from: node2D),
                nodes2D.closestNode(to: .southeast, from: node2D),
                nodes2D.closestNode(to: .southwest, from: node2D),
                ]
            
            let pointsToConnectArray = pointsToConnectArrayNullable.flatMap{ $0?.position }
            let pointsToConnect = Set<vector_float2>(pointsToConnectArray)
//            [
            
//                vector_float2(node2D.position.x - 1, node2D.position.y - 1),
//                vector_float2(node2D.position.x + 0, node2D.position.y - 1),
//                vector_float2(node2D.position.x + 1, node2D.position.y - 1),
//                vector_float2(node2D.position.x - 1, node2D.position.y),
//                vector_float2(node2D.position.x + 1, node2D.position.y),
//                vector_float2(node2D.position.x - 1, node2D.position.y + 1),
//                vector_float2(node2D.position.x + 0, node2D.position.y + 1),
//                vector_float2(node2D.position.x + 1, node2D.position.y + 1),
//            ]
            
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
            let nonConnectedNodes = nodesToConnect.filter{ !node2D.connectedNodes.contains($0) }
            node2D.addConnections(to: nonConnectedNodes, bidirectional: false)
        }
//        print(self.entity!.className)
//        print("nodes:", graph.nodes!.count)
//        print("edges:", graph.nodes!.reduce(into: 0, { $0 += $1.connectedNodes.count }))
        guard let path = graph.findPath(from: sourceNode, to: destinationNode) as? [GKGraphNode2D] else { fatalError("GKGraphNode2D should be used here") }
        
        let points: [CGPoint] = path.map{
            let coordinate = Coordinate(x: Int($0.position.x), y: Int($0.position.y))
            return GridComponent.position(for: coordinate)
            
        }
        
        self.path = points.map{ Coordinate(x: Int($0.x), y: Int($0.y)) }
        
        if( points.isEmpty ) {
            print("\n\tNo Connection from \(source) to \(destination)\n")
        } else {
            print("Sucess Wiring")
        }
        
        self.wireNode = WireNode(points: points)
        self.parentNode.addChild(self.wireNode)
    }
    
}

extension WireComponent: RenderableComponent {
    var node: SKNode {
        return self.parentNode
    }
}

extension vector_float2: Hashable {
    public var hashValue: Int {
        return self.x.hashValue + self.y.hashValue
    }
}

enum Orientation {
    case north
    case south
    case east
    case west
    case northeast
    case northwest
    case southeast
    case southwest
}

extension Collection where Element == GKGraphNode2D {
    
    func closestNode(to orientation: Orientation, from node: GKGraphNode2D) -> GKGraphNode2D? {
        switch orientation {
        case .north: return self.searchNodeBasedInPosition(from: node, xIncrement: 0, yIncrement: 1)
        case .south: return self.searchNodeBasedInPosition(from: node, xIncrement: 0, yIncrement: -1)
        case .east: return self.searchNodeBasedInPosition(from: node, xIncrement: 1, yIncrement: 0)
        case .west: return self.searchNodeBasedInPosition(from: node, xIncrement: -1, yIncrement: 0)
        case .northeast: return self.searchNodeBasedInPosition(from: node, xIncrement: 1, yIncrement: 1)
        case .northwest: return self.searchNodeBasedInPosition(from: node, xIncrement: -1, yIncrement: 1)
        case .southeast: return self.searchNodeBasedInPosition(from: node, xIncrement: 1, yIncrement: -1)
        case .southwest: return self.searchNodeBasedInPosition(from: node, xIncrement: -1, yIncrement: -1)
        }
    }
    
    private func searchNodeBasedInPosition(from baseNode: GKGraphNode2D, xIncrement: Int, yIncrement: Int) -> GKGraphNode2D? {
        
        // Filter array
        let controlPosition = baseNode.position
        let nodes = self.filter{
                
            // Avoid returning self
            if( $0 != baseNode ) {
               
                // Normalize position centering in the control position
                let offsetVector = vector2($0.position.x - controlPosition.x ,$0.position.y - controlPosition.y)
                
                // To check it, we'll use a simple math trick
                // First Check if there's an integer multipler that can get us from the control point to the $0.position
                // Next Test if the same applies from the expected sum
                
                // X
                let xIsCorrect: Bool
                if( xIncrement == 0 ) {
                    xIsCorrect = offsetVector.x == 0
                } else {
                    xIsCorrect = Int(offsetVector.x) % xIncrement == 0 && ( xIncrement < 0 ? offsetVector.x < 0 : offsetVector.x > 0 )
                }
                
                // Y
                let yIsCorrect: Bool
                if( yIncrement == 0 ) {
                    yIsCorrect = offsetVector.y == 0
                } else {
                    yIsCorrect = Int(offsetVector.y) % yIncrement == 0 && ( yIncrement < 0 ? offsetVector.y < 0 : offsetVector.y > 0 )
                }
                
                // Sum
                let offsetSum = offsetVector.x + offsetVector.y
                let incrementSum = xIncrement + yIncrement
                let sumIsCorrect: Bool
                if( incrementSum == 0 ) {
                    sumIsCorrect = offsetSum == 0
                } else {
                   sumIsCorrect = Int(offsetSum) % (incrementSum) == 0 && ( incrementSum < 0 ? offsetSum < 0 : offsetSum > 0 )
                }
                
                
                return xIsCorrect && yIsCorrect && sumIsCorrect
            }
            return false
        }
        
        // Get node with the lowest distance to control point
        return nodes.min { controlPosition.distance(to: $0.position) < controlPosition.distance(to: $1.position) }
    }
}

extension vector_float2 {
    // Pythagorean Theorem
    func distance(to point: vector_float2) -> Float {
        let deltaX = self.x - point.x
        let deltaY = self.y - point.y
        return sqrt(deltaX*deltaX + deltaY*deltaY)
    }
}
