//
//  Ring+Split.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/2/23.
//

import Foundation

extension Ring {
    
    //
    // At the end of this, if it returns false, the split cannot be used.
    // If it returns true, safety check A and B will be done on splitRing1 and splitRing2;
    // Note: This is still not "bullet proof" as further ear clipping may occur.
    //
    func split(splitRing1: Ring, splitRing2: Ring, index1: Int, index2: Int, count: Int) -> Bool {
        
        if ringPointCount < 4 {
            print("[P9Yh4] ringPointCount \(ringPointCount) < 4")
            return false
        }
        
        if index1 < 0 || index1 >= ringPointCount {
            print("[P9Yh5] index1 \(index1) out of range \(ringPointCount)")
            return false
        }
        
        if index2 < 0 || index2 >= ringPointCount {
            print("[P9Yh6] index2 \(index1) out of range \(ringPointCount)")
            return false
        }
        
        if Math.polygonIndexDistance(index1: index1, index2: index2, count: ringPointCount) < 2 {
            print("[P9Yh7] index1 \(index1) index2 \(index2) too close, dist = \(Math.polygonIndexDistance(index1: index1, index2: index2, count: ringPointCount))")
            return false
        }
        
        if count < 0 || count > 2 {
            print("[P9Yh8] count \(count) must be 0, 1, or 2.")
            return false
        }
        
        let splitRingPoint1 = ringPoints[index1]
        let splitRingPoint2 = ringPoints[index2]
        
        if count == 0 {
            splitRing1.addPoint(splitRingPoint1.x, splitRingPoint1.y)
            splitRing1.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            splitRing2.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            splitRing2.addPoint(splitRingPoint1.x, splitRingPoint1.y)
        } else if count == 1 {
            let centerX = (splitRingPoint1.x + splitRingPoint2.x) * 0.5
            let centerY = (splitRingPoint1.y + splitRingPoint2.y) * 0.5

            splitRing1.addPoint(splitRingPoint1.x, splitRingPoint1.y)
            splitRing1.addPoint(centerX, centerY)
            splitRing1.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            splitRing2.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            splitRing2.addPoint(centerX, centerY)
            splitRing2.addPoint(splitRingPoint1.x, splitRingPoint1.y)
        } else {
            let deltaX = splitRingPoint2.x - splitRingPoint1.x
            let deltaY = splitRingPoint2.y - splitRingPoint1.y
            let centerX1 = splitRingPoint1.x + deltaX * 0.35
            let centerY1 = splitRingPoint1.y + deltaY * 0.35
            let centerX2 = splitRingPoint1.x + deltaX * 0.65
            let centerY2 = splitRingPoint1.y + deltaY * 0.65

            splitRing1.addPoint(splitRingPoint1.x, splitRingPoint1.y)
            splitRing1.addPoint(centerX1, centerY1)
            splitRing1.addPoint(centerX2, centerY2)
            splitRing1.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            
            splitRing2.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            splitRing2.addPoint(centerX2, centerY2)
            splitRing2.addPoint(centerX1, centerY1)
            splitRing2.addPoint(splitRingPoint1.x, splitRingPoint1.y)
        }
        
        var ringPointIndex = index2 + 1
        if ringPointIndex == ringPointCount {
            ringPointIndex = 0
        }
        while ringPointIndex != index1 {
            let ringPoint = ringPoints[ringPointIndex]
            splitRing1.addPoint(ringPoint.x, ringPoint.y)
            ringPointIndex += 1
            if ringPointIndex == ringPointCount {
                ringPointIndex = 0
            }
        }
        
        ringPointIndex = index1 + 1
        if ringPointIndex == ringPointCount {
            ringPointIndex = 0
        }
        while ringPointIndex != index2 {
            let ringPoint = ringPoints[ringPointIndex]
            splitRing2.addPoint(ringPoint.x, ringPoint.y)
            ringPointIndex += 1
            if ringPointIndex == ringPointCount {
                ringPointIndex = 0
            }
        }
        
        if !splitRing1.attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
            return false
        }
        
        if !splitRing2.attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
            return false
        }
        
        if !splitRing1.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, needsLineSegmentBucket: true, test: false) {
            return false
        }
        
        if !splitRing2.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, needsLineSegmentBucket: true, test: false) {
            return false
        }
        
        splitRing1.depth = depth + 1
        splitRing2.depth = depth + 1
        
        return true
    }
    
    //@Precondition: calculatePossibleSplits is called
    /*
    func attemptValidSplit() -> Bool {
        
        //
        //return false
        
        
        purgeRingSplits()
        
        let splitRing1 = partsFactory.withdrawRing(polyMesh: polyMesh)
        let splitRing2 = partsFactory.withdrawRing(polyMesh: polyMesh)
        
        for possibleSplitPairIndex in 0..<possibleSplitPairCount {
            
            let possibleSplitPair = possibleSplitPairs[possibleSplitPairIndex]
            
            let index1 = possibleSplitPair.ringPoint1.ringIndex
            let index2 = possibleSplitPair.ringPoint2.ringIndex
            
            let splitCount = getSplitPointCount(index1: index1,
                                           index2: index2)
            
            split(index1: index1,
                  index2: index2,
                  splitCount: splitCount,
                  ring1: splitRing1,
                  ring2: splitRing2)
            
            if splitRing1.ringPointCount < 3 { continue }
            if splitRing2.ringPointCount < 3 { continue }
        
            if !splitRing1.attemptCalculateBasicsAndDetermineSafetyPartA(test: true) { continue }
            if !splitRing2.attemptCalculateBasicsAndDetermineSafetyPartA(test: true) { continue }
            
            if !splitRing1.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, 
                                                                  needsLineSegmentBucket: true,
                                                                  test: true) { continue }
            if !splitRing2.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, 
                                                                  needsLineSegmentBucket: true,
                                                                  test: true) { continue }
            
            splitRing1.calculateSplitQuality(splitCount: splitCount)
            splitRing2.calculateSplitQuality(splitCount: splitCount)
            
            if !(splitRing1.splitQuality.isBroken || splitRing2.splitQuality.isBroken) {
                let ringSplit = partsFactory.withdrawRingSplit()
                
                ringSplit.index1 = possibleSplitPair.ringPoint1.ringIndex
                ringSplit.index2 = possibleSplitPair.ringPoint2.ringIndex
                ringSplit.splitQuality.earAngle = min(splitRing1.splitQuality.earAngle, splitRing2.splitQuality.earAngle)
                
                
                //ringSplit.splitQuality.pointCloseness = .great
                ringSplit.splitQuality.pointCloseness = min(splitRing1.splitQuality.pointCloseness, splitRing2.splitQuality.pointCloseness)
                ringSplit.splitQuality.numberOfPoints = min(splitRing1.splitQuality.numberOfPoints, splitRing2.splitQuality.numberOfPoints)
                ringSplit.splitQuality.splitLength = min(splitRing1.splitQuality.splitLength, splitRing2.splitQuality.splitLength)
                ringSplit.splitQuality.calculateWeight()
                
                addRingSplit(ringSplit)
            }
        }
        
        if POLY_MESH_MONO_SPLIT_ENABLED {
            if depth == POLY_MESH_MONO_SPLIT_LEVEL {
                
            } else {
                partsFactory.depositRing(splitRing1)
                partsFactory.depositRing(splitRing2)
                
                
                return false
            }
        } else {
            if POLY_MESH_OMNI_SPLIT_ENABLED && (depth <= POLY_MESH_OMNI_SPLIT_LEVEL) {
                
            } else {
                partsFactory.depositRing(splitRing1)
                partsFactory.depositRing(splitRing2)
                
                return false
            }
        }
        
        
        if ringSplitCount > 0 {
            
            var bestSplit = ringSplits[0]
            var index = 1
            while index < ringSplitCount {
                let ringSplit = ringSplits[index]
                if ringSplit.splitQuality > bestSplit.splitQuality {
                    bestSplit = ringSplit
                }
                index += 1
            }
            
            let splitCount = getSplitPointCount(index1: bestSplit.index1,
                                           index2: bestSplit.index2)
            
            split(index1: bestSplit.index1,
                  index2: bestSplit.index2,
                  splitCount: splitCount,
                  ring1: splitRing1,
                  ring2: splitRing2)
            
            if splitRing1.ringPointCount < 3 {
                print("FATAL ERROR: Split ring 1 has < 3 points")
            }
            
            if splitRing2.ringPointCount < 3 {
                print("FATAL ERROR: Split ring 2 has < 3 points")
            }
            
            _ = splitRing1.attemptCalculateBasicsAndDetermineSafetyPartA(test: false)
            _ = splitRing1.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, needsLineSegmentBucket: true, test: false)
            
            splitRing1.depth = depth + 1
            addSubring(splitRing1)
            
            _ = splitRing2.attemptCalculateBasicsAndDetermineSafetyPartA(test: false)
            _ = splitRing2.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true, needsLineSegmentBucket: true, test: false)
            
            splitRing2.depth = depth + 1
            addSubring(splitRing2)

            purgeRingPoints()
            purgeLineSegments()
            
            purgePossibleSplitPairs()
            purgeRingSplits()
            
            ringLineSegmentBucket.reset()
            
            // We did split.
            return true
        }
        
        // Found no split.
        
        partsFactory.depositRing(splitRing1)
        partsFactory.depositRing(splitRing2)
        
        return false
    }
    
    func split(index1: Int, index2: Int, splitCount: Int, ring1: Ring, ring2: Ring) {
        partsFactory.depositRingContent(ring1)
        partsFactory.depositRingContent(ring2)
        if index1 >= 0 && index1 < ringPointCount,
           index2 >= 0 && index2 < ringPointCount,
           Math.polygonIndexDistance(index1: index1, index2: index2, count: ringPointCount) > 1
        {
            let splitRingPoint1 = ringPoints[index1]
            let splitRingPoint2 = ringPoints[index2]
            var splicePoints = [Point]()
            if splitCount > 0 {
                var diffX = splitRingPoint2.x - splitRingPoint1.x
                var diffY = splitRingPoint2.y - splitRingPoint1.y
                var length = diffX * diffX + diffY * diffY
                if length > Math.epsilon {
                    length = sqrtf(length)
                    diffX /= length
                    diffY /= length
                    var spliceIndex = 0
                    while spliceIndex < splitCount {
                        let percent = Float(spliceIndex + 1) / Float(splitCount + 1)
                        let x = splitRingPoint1.x + diffX * length * percent
                        let y = splitRingPoint1.y + diffY * length * percent
                        let point = Point(x: x, y: y)
                        splicePoints.append(point)
                        spliceIndex += 1
                    }
                } else {
                    return
                }
            }
            
            
            ring1.addPoint(splitRingPoint1.x, splitRingPoint1.y)
            var spliceIndex = 0
            while spliceIndex < splicePoints.count {
                ring1.addPoint(splicePoints[spliceIndex].x, splicePoints[spliceIndex].y)
                spliceIndex += 1
            }
            ring1.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            var ringPointIndex = index2 + 1
            if ringPointIndex == ringPointCount {
                ringPointIndex = 0
            }
            while ringPointIndex != index1 {
                ring1.addPoint(ringPoints[ringPointIndex].x, ringPoints[ringPointIndex].y)
                ringPointIndex += 1
                if ringPointIndex == ringPointCount {
                    ringPointIndex = 0
                }
            }
            
            ring2.addPoint(splitRingPoint2.x, splitRingPoint2.y)
            spliceIndex = splicePoints.count - 1
            while spliceIndex >= 0 {
                ring2.addPoint(splicePoints[spliceIndex].x, splicePoints[spliceIndex].y)
                spliceIndex -= 1
            }
            ring2.addPoint(splitRingPoint1.x, splitRingPoint1.y)
            ringPointIndex = index1 + 1
            if ringPointIndex == ringPointCount {
                ringPointIndex = 0
            }
            while ringPointIndex != index2 {
                ring2.addPoint(ringPoints[ringPointIndex].x, ringPoints[ringPointIndex].y)
                ringPointIndex += 1
                if ringPointIndex == ringPointCount {
                    ringPointIndex = 0
                }
            }
        }
    }
    
    func getSplitPointCount(index1: Int, index2: Int) -> Int {
        var result = 0
        if index1 >= 0 && index1 < ringPointCount,
           index2 >= 0 && index2 < ringPointCount
        {
            let point1 = ringPoints[index1].point
            let point2 = ringPoints[index2].point
            
            let splitLineIntoTwoPointsDistance = (PolyMeshConstants.splitLineIntoTwoPointsDistance)
            let splitLineIntoTwoPointsDistanceSquared = splitLineIntoTwoPointsDistance * splitLineIntoTwoPointsDistance
            
            if point1.distanceSquaredTo(point2) > splitLineIntoTwoPointsDistanceSquared {
                result = 1
            }
        }
        return result
    }
    */
    
}
