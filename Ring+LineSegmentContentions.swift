//
//  Ring+ContendingLineSegments.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/29/23.
//

import Foundation

extension Ring {
    
    //
    // Note: This seems to work good, I don't see any reason to change, improve, or re-do this.
    //
    
    //@Precondition: ringPointInsidePolygonBucket is populated
    //@Precondition: ringLineSegmentBucket is populated
    //@Precondition: calculateRingPointPinchGates is called
    func calculateLineSegmentContentions() {
        
        for ringPointIndex in 0..<ringPointCount {
            ringPoints[ringPointIndex].purgeLineSegmentContentions(partsFactory: partsFactory)
        }
        
        for ringPointIndex in 0..<ringPointCount {
            let ringPoint = ringPoints[ringPointIndex]
            
            let pinchGateRightIndex = ringPoint.pinchGateRightIndex
            let pinchGateLeftIndex = ringPoint.pinchGateLeftIndex
            
            if pinchGateRightIndex != -1 && pinchGateLeftIndex != -1 {
            
                ringLineSegmentBucket.query(minX: ringPoint.x - PolyMeshConstants.ringContentionDistance,
                                            maxX: ringPoint.x + PolyMeshConstants.ringContentionDistance,
                                            minY: ringPoint.y - PolyMeshConstants.ringContentionDistance,
                                            maxY: ringPoint.y + PolyMeshConstants.ringContentionDistance)
                
                for bucketLineSegmentIndex in 0..<ringLineSegmentBucket.ringLineSegmentCount {
                    let bucketLineSegment = ringLineSegmentBucket.ringLineSegments[bucketLineSegmentIndex]
                    let ringLineSegmentIndex = Int(bucketLineSegment.ringIndex)
                    if Math.polygonTourCrosses(index: ringLineSegmentIndex, startIndex: pinchGateRightIndex, endIndex: pinchGateLeftIndex) {
                        if isSafeConnection(ringPoint: ringPoint,
                                            ringLineSegment: bucketLineSegment) {
                            let distanceSquared = bucketLineSegment.distanceSquaredToClosestPoint(ringPoint.x, ringPoint.y)
                            if distanceSquared <= PolyMeshConstants.ringContentionDistanceSquared  {
                                let lineSegmentContention = partsFactory.withdrawLineSegmentContention()
                                lineSegmentContention.ringLineSegment = bucketLineSegment
                                lineSegmentContention.distanceSquared = distanceSquared
                                ringPoint.addLineSegmentContention(lineSegmentContention)
                            }
                        }
                    }
                }
            }
        }
    }
}
