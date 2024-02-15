//
//  PolyMeshPoint.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/15/23.
//

import Foundation

class RingPoint: PointProtocol {
    
    typealias ThreatLevel = RingLineSegment.ThreatLevel
    
    typealias Point = Math.Point
    typealias Vector = Math.Vector
    
    var x = Float(0.0)
    var y = Float(0.0)
    
    var meshPoint = RingMeshPoint()
    func refreshMeshPoint() {
        meshPoint.x = x
        meshPoint.y = y
    }
    
    var connections = [RingPoint]()
    var connectionCount = 0
    func addConnection(_ connection: RingPoint) {
        while connections.count <= connectionCount {
            connections.append(connection)
        }
        connections[connectionCount] = connection
        connectionCount += 1
    }
    
    var isIllegal = false
    var isChecked = false
    
    //var isPinch = false
    //var isTagged = false
    
    var isCornerOutlier = false
    
    
    var baseProbeX = Float(0.0)
    var baseProbeY = Float(0.0)
    var baseProbeLength = Float(0.0)
    
    
    
    //var cornerOutlierPatchPoint1X = Float(0.0)
    //var cornerOutlierPatchPoint1Y = Float(0.0)
    
    //var cornerOutlierPatchPoint2X = Float(0.0)
    //var cornerOutlierPatchPoint2Y = Float(0.0)
    
    //var cornerOutlierPatchPoint3X = Float(0.0)
    //var cornerOutlierPatchPoint3Y = Float(0.0)
    
    
    //var cornerOutlierPatchValid1 = false
    //var cornerOutlierPatchValid2 = false (Always YES)
    //var cornerOutlierPatchValid3 = false
    
    var triangleIndex = UInt32(0)
    
    var ringIndex: Int = 0
    
    var angularSpan = Float(0.0)
    
    //var ringLineSegmentRightIndex: Int = 0
    //var ringLineSegmentLeftIndex: Int = 0
    
    
    
    //var primaryProbePointIndex: Int = 0
    
    var threatLevel = ThreatLevel.none
    
    unowned var ringLineSegmentLeft: RingLineSegment!
    unowned var ringLineSegmentRight: RingLineSegment!
    
    unowned var probeSegmentForCollider: RingProbeSegment!
    
    unowned var neighborLeft: RingPoint!
    unowned var neighborRight: RingPoint!
    
    var lineSegmentContentions = [LineSegmentContention]()
    var lineSegmentContentionCount = 0
    func addLineSegmentContention(_ lineSegmentContention: LineSegmentContention) {
        while lineSegmentContentions.count <= lineSegmentContentionCount {
            lineSegmentContentions.append(lineSegmentContention)
        }
        lineSegmentContentions[lineSegmentContentionCount] = lineSegmentContention
        lineSegmentContentionCount += 1
    }
    func purgeLineSegmentContentions(partsFactory: PolyMeshPartsFactory) {
        for lineSegmentContentionIndex in 0..<lineSegmentContentionCount {
            let lineSegmentContention = lineSegmentContentions[lineSegmentContentionIndex]
            partsFactory.depositLineSegmentContention(lineSegmentContention)
        }
        lineSegmentContentionCount = 0
    }
    
    var possibleSplits = [PossibleSplit]()
    var possibleSplitCount = 0
    func addPossibleSplit(_ possibleSplit: PossibleSplit) {
        while possibleSplits.count <= possibleSplitCount {
            possibleSplits.append(possibleSplit)
        }
        possibleSplits[possibleSplitCount] = possibleSplit
        possibleSplitCount += 1
    }
    
    func possibleSplitsContains(ringPoint: RingPoint) -> Bool {
        for possibleSplitIndex in 0..<possibleSplitCount {
            if possibleSplits[possibleSplitIndex].ringPoint === ringPoint {
                return true
            }
        }
        return false
    }
    
    func purgePossibleSplits(partsFactory: PolyMeshPartsFactory) {
        for possibleSplitIndex in 0..<possibleSplitCount {
            let possibleSplit = possibleSplits[possibleSplitIndex]
            partsFactory.depositPossibleSplit(possibleSplit)
        }
        possibleSplitCount = 0
    }
    
    var pinchGateLeftIndex = -1
    var pinchGateRightIndex = -1
    var pinchGateSpan = 0
    
    var directionX = Float(0.0)
    var directionY = Float(-1.0)
    
    var normalX = Float(1.0)
    var normalY = Float(0.0)
    
    //var normal = Vector(x: 0.0, y: -1.0)
    var normalAngle = Float(0.0)

    var point: Point {
        Point(x: x,
              y: y)
    }
    
    func distanceSquared(x: Float, y: Float) -> Float {
        let diffX = x - self.x
        let diffY = y - self.y
        return diffX * diffX + diffY * diffY
    }
    
    func distanceSquared(ringPoint: RingPoint) -> Float {
        let diffX = ringPoint.x - x
        let diffY = ringPoint.y - y
        return diffX * diffX + diffY * diffY
    }
    
    init() {
        //print("Spawned RingPoint")
    }
    
    deinit {
        print("Dealloc RingPoint")
    }
    
    func writeToFastSplit(_ ringPoint: RingPoint) {
        ringPoint.x = x
        ringPoint.y = y
        ringPoint.angularSpan = angularSpan
        ringPoint.directionX = directionX
        ringPoint.directionY = directionY
        ringPoint.normalX = normalX
        ringPoint.normalY = normalY
        ringPoint.normalAngle = normalAngle
        ringPoint.isIllegal = isIllegal
    }
}

extension RingPoint: CustomStringConvertible {
    var description: String {
        let stringX = String(format: "%.1f", x)
        let stringy = String(format: "%.1f", y)
        return "{\(stringX), \(stringy)}"
    }
}
