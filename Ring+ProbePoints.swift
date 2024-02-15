//
//  Ring+ProbePoints.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/7/24.
//

import Foundation

extension Ring {
    
    func calculateProbePointsFromColliders() {
        
        //purgeProbePoints()
        ringProbePointCount = 0
        
        //var baseProbeX = Float(0.0)
        //var baseProbeY = Float(0.0)
        //var baseProbeLength = Float(0.0)
        
        
        //var ringPointIndexPrevious = ringPointCount - 1
        //var ringPointIndex = 0
        //var ringPointNext = 1
        
        for ringPointIndex in 0..<ringPointCount {
            
            let ringPoint = ringPoints[ringPointIndex]
            if ringPoint.isCornerOutlier {
                ringPoint.baseProbeX = ringPoint.x + ringPoint.normalX * ringPoint.baseProbeLength
                ringPoint.baseProbeY = ringPoint.y + ringPoint.normalY * ringPoint.baseProbeLength
            } else {
                ringPoint.baseProbeX = ringPoint.probeSegmentForCollider.colliderPointX
                ringPoint.baseProbeY = ringPoint.probeSegmentForCollider.colliderPointY
            }
        }
        
        for ringPointIndex in 0..<ringPointCount {
            
            let ringPoint = ringPoints[ringPointIndex]
            
            if ringPoint.isCornerOutlier {
                
                var ringPointIndexPrevious = ringPointIndex - 1
                if ringPointIndexPrevious < 0 { ringPointIndexPrevious = ringPointCount - 1 }
                
                let ringPointPrevious = ringPoints[ringPointIndexPrevious]
                if ringPointPrevious.isCornerOutlier {
                    
                    // In this case, we will have already added the patch for both,
                    // or we will be adding it later...
                    
                } else {
                    
                    // Pick an elite point going backwards...
                    
                    var x = ringPoint.baseProbeX - ringPoint.ringLineSegmentLeft.directionX * PolyMeshConstants.probeButtressDefaultDistance
                    var y = ringPoint.baseProbeY - ringPoint.ringLineSegmentLeft.directionY * PolyMeshConstants.probeButtressDefaultDistance
                    var closestPoint = ringPoint.ringLineSegmentLeft.closestPoint(x, y)
                    x = closestPoint.x + ringPoint.ringLineSegmentLeft.normalX * ringPoint.baseProbeLength
                    y = closestPoint.y + ringPoint.ringLineSegmentLeft.normalY * ringPoint.baseProbeLength
                    let distanceToPreviousSquared = Math.distanceSquared(x1: x, y1: y, x2: ringPointPrevious.baseProbeX, y2: ringPointPrevious.baseProbeY)
                    
                    let ringProbePoint = partsFactory.withdrawRingProbePoint()
                    
                    if distanceToPreviousSquared < PolyMeshConstants.probeButtressMergeDistanceSquared {
                        x = (ringPoint.baseProbeX + ringPointPrevious.baseProbeX) * 0.5
                        y = (ringPoint.baseProbeY + ringPointPrevious.baseProbeY) * 0.5
                        closestPoint = ringPoint.ringLineSegmentLeft.closestPoint(x, y)
                        x = closestPoint.x + ringPoint.ringLineSegmentLeft.normalX * ringPoint.baseProbeLength
                        y = closestPoint.y + ringPoint.ringLineSegmentLeft.normalY * ringPoint.baseProbeLength
                        //ringProbePoint.connections.append(ringPointPrevious)
                        ringProbePoint.addConnection(ringPointPrevious)
                    }
                    ringProbePoint.setup(x: x, y: y)
                    addRingProbePoint(ringProbePoint)
                    ringProbePoint.addConnection(ringPoint)
                    ringProbePoint.isButtressCenter = false
                }
                
                let ringProbePoint = partsFactory.withdrawRingProbePoint()
                ringProbePoint.setup(x: ringPoint.baseProbeX, y: ringPoint.baseProbeY)
                
                addRingProbePoint(ringProbePoint)
                ringProbePoint.addConnection(ringPoint)
                
                ringProbePoint.isButtressCenter = true
                
                var ringPointNextIndex = ringPointIndex + 1
                if ringPointNextIndex == ringPointCount { ringPointNextIndex = 0 }
                
                let ringPointNext = ringPoints[ringPointNextIndex]
                if ringPointNext.isCornerOutlier {
                    
                    // Pick an elite point going forward...
                    let ringProbePoint = partsFactory.withdrawRingProbePoint()
                    var x = (ringPoint.baseProbeX + ringPointNext.baseProbeX) * 0.5
                    var y = (ringPoint.baseProbeY + ringPointNext.baseProbeY) * 0.5
                    let closestPoint = ringPoint.ringLineSegmentRight.closestPoint(x, y)
                    x = closestPoint.x + ringPoint.ringLineSegmentRight.normalX * ringPoint.baseProbeLength
                    y = closestPoint.y + ringPoint.ringLineSegmentRight.normalY * ringPoint.baseProbeLength
                    ringProbePoint.setup(x: x, y: y)
                    addRingProbePoint(ringProbePoint)
                    ringProbePoint.connections.append(ringPoint)
                    ringProbePoint.isButtressCenter = false
                    ringProbePoint.addConnection(ringPointNext)
                    
                } else {
                    
                    // Pick an elite point going forward...
                    var x = ringPoint.baseProbeX + ringPoint.ringLineSegmentRight.directionX * PolyMeshConstants.probeButtressDefaultDistance
                    var y = ringPoint.baseProbeY + ringPoint.ringLineSegmentRight.directionY * PolyMeshConstants.probeButtressDefaultDistance
                    var closestPoint = ringPoint.ringLineSegmentRight.closestPoint(x, y)
                    x = closestPoint.x + ringPoint.ringLineSegmentRight.normalX * ringPoint.baseProbeLength
                    y = closestPoint.y + ringPoint.ringLineSegmentRight.normalY * ringPoint.baseProbeLength
                    
                    let distanceToNextSquared = Math.distanceSquared(x1: x, y1: y, x2: ringPointNext.baseProbeX, y2: ringPointNext.baseProbeY)
                    
                    let ringProbePoint = partsFactory.withdrawRingProbePoint()
                    var isShared = false
                    if distanceToNextSquared < PolyMeshConstants.probeButtressMergeDistanceSquared {
                        x = (ringPoint.baseProbeX + ringPointNext.baseProbeX) * 0.5
                        y = (ringPoint.baseProbeY + ringPointNext.baseProbeY) * 0.5
                        closestPoint = ringPoint.ringLineSegmentRight.closestPoint(x, y)
                        x = closestPoint.x + ringPoint.ringLineSegmentRight.normalX * ringPoint.baseProbeLength
                        y = closestPoint.y + ringPoint.ringLineSegmentRight.normalY * ringPoint.baseProbeLength
                        isShared = true
                    }
                    ringProbePoint.setup(x: x, y: y)
                    addRingProbePoint(ringProbePoint)
                    ringProbePoint.addConnection(ringPoint)
                    
                    ringProbePoint.isButtressCenter = false
                    if isShared {
                        ringProbePoint.connections.append(ringPointNext)
                    }
                }
            } else {
                let ringPoint = ringPoints[ringPointIndex]
                let ringProbePoint = partsFactory.withdrawRingProbePoint()
                ringProbePoint.setup(x: ringPoint.baseProbeX,
                                     y: ringPoint.baseProbeY)
                addRingProbePoint(ringProbePoint)
                ringProbePoint.addConnection(ringPoint)
                ringProbePoint.isButtressCenter = false
            }
        }
        
        calculateRingProbePointIndices()
        calculateProbePointNeighbors()
        
    }
    
    func calculateProbeSegmentsUsingProbePoints() {
        
        purgeProbeSegments()
        //ringProbeSegmentCount = 0
        
        var ringProbePointIndex1 = 0
        var ringProbePointIndex2 = 1
        while ringProbePointIndex1 < ringProbePointCount {
            let ringProbePointLeft = ringProbePoints[ringProbePointIndex1]
            let ringProbePointRight = ringProbePoints[ringProbePointIndex2]
            
            let ringProbeSegment = partsFactory.withdrawProbeSegment()
            
            ringProbeSegment.x1 = ringProbePointLeft.x
            ringProbeSegment.y1 = ringProbePointLeft.y
            
            ringProbeSegment.x2 = ringProbePointRight.x
            ringProbeSegment.y2 = ringProbePointRight.y
            ringProbeSegment.precompute()
            
            addRingProbeSegment(ringProbeSegment)
            
            ringProbePointIndex1 += 1
            ringProbePointIndex2 += 1
            if ringProbePointIndex2 == ringProbePointCount {
                ringProbePointIndex2 = 0
            }
        }
        
        calculateProbeSegmentIndices()
        calculateProbeSegmentPointNeighbors()
        calculateProbeSegmentNeighbors()
        calculateProbePointProbeSegmentNeighbors()
    }
}
