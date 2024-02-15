//
//  Ring+MeldProbePoints.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/3/24.
//

import Foundation

extension Ring {
    
    // We should ALWAYS flush. The whole advantage of the fast
    // geometry update is that we can quickly re-calculate
    // the contentions and things... Better to be accurate than redundant
    func meldProbePoints(ringMeld: RingMeld) -> Bool {
    
        guard ringMeld.ringProbePointCount > 1 else {
            print("[J718] Meld ringMeld.ringProbePointCount \(ringMeld.ringProbePointCount) must be > 1")
            return false
        }
        
        /*
        var temp_1_ringMelds = [RingMeld]()
        var temp_1_ringMeldCount = 0
        func addTemp_1_RingMeld(_ ringMeld: RingMeld) {
            while temp_1_ringMelds.count <= temp_1_ringMeldCount {
                temp_1_ringMelds.append(ringMeld)
            }
            temp_1_ringMelds[temp_1_ringMeldCount] = ringMeld
            temp_1_ringMeldCount += 1
        }
        */
        
        
        // Step 0.) Remove the relevant probe segments from bucket...
        
        let meldProbePointCount = ringMeld.ringProbePointCount
        let meldProbePointCount1 = meldProbePointCount - 1
        
        let firstProbeSegment = ringMeld.ringProbePoints[0].ringProbeSegmentLeft!
        let lastProbeSegment = ringMeld.ringProbePoints[meldProbePointCount1].ringProbeSegmentRight!
        
        guard firstProbeSegment !== lastProbeSegment else {
            print("[J53E] Meld firstProbeSegment === lastProbeSegment")
            return false
        }
        
        temp_1_ringProbePointCount = 0
        for ringProbePointIndex in 0..<ringMeld.ringProbePointCount {
            let ringProbePoint = ringMeld.ringProbePoints[ringProbePointIndex]
            addTemp_1_RingProbePoint(ringProbePoint)
        }
        
        temp_1_ringProbeSegmentCount = 0
        var fudge = 0
        var ringProbeSegment = firstProbeSegment
        while true {
            addTemp_1_RingProbeSegment(ringProbeSegment)
            if ringProbeSegment === lastProbeSegment {
                break
            } else {
                ringProbeSegment = ringProbeSegment.neighborRight!
            }
            fudge += 1
            if fudge >= 32 {
                // Note: This has triggered before
                print("[Q3PL9] Infinite loop, meldProbePoints, flush ps bucket.")
                break
            }
        }
        
        let firstProbePoint = ringMeld.ringProbePoints[0]
        let lastProbePoint = ringMeld.ringProbePoints[ringMeld.ringProbePointCount - 1]
        
        
        let newProbePoint = partsFactory.withdrawRingProbePoint()
        newProbePoint.x = ringMeld.x
        newProbePoint.y = ringMeld.y
        
        for ringProbePointIndex in 0..<ringMeld.ringProbePointCount {
            let ringProbePoint = ringMeld.ringProbePoints[ringProbePointIndex]
            for connectionIndex in 0..<ringProbePoint.connectionCount {
                let connection = ringProbePoint.connections[connectionIndex]
                if !(newProbePoint.connectionCount > 0 && newProbePoint.connections[newProbePoint.connectionCount - 1] === connection) {
                    newProbePoint.addConnection(connection)
                }
            }
        }
        
        meldReplaceProbePointRangeWithOneProbePoint(startIndex: firstProbePoint.ringIndex,
                                                    endIndex: lastProbePoint.ringIndex,
                                                    newProbePoint)
        
        let newProbeSegment1 = partsFactory.withdrawProbeSegment()
        newProbeSegment1.x1 = newProbePoint.neighborLeft.x
        newProbeSegment1.y1 = newProbePoint.neighborLeft.y
        newProbeSegment1.x2 = ringMeld.x
        newProbeSegment1.y2 = ringMeld.y
        newProbeSegment1.precompute()
        ringProbeSegmentBucket.add(ringProbeSegment: newProbeSegment1)
        
        let newProbeSegment2 = partsFactory.withdrawProbeSegment()
        newProbeSegment2.x1 = ringMeld.x
        newProbeSegment2.y1 = ringMeld.y
        newProbeSegment2.x2 = newProbePoint.neighborRight.x
        newProbeSegment2.y2 = newProbePoint.neighborRight.y
        newProbeSegment2.precompute()
        ringProbeSegmentBucket.add(ringProbeSegment: newProbeSegment2)
        
        meldReplaceProbeSegmentRangeWithTwoProbeSegments(startIndex: firstProbeSegment.ringIndex,
                                                         endIndex: lastProbeSegment.ringIndex,
                                                         newProbeSegment1,
                                                         newProbeSegment2)
        
        newProbeSegment1.ringProbePointLeft = newProbePoint.neighborLeft
        newProbeSegment1.ringProbePointRight = newProbePoint
        newProbeSegment2.ringProbePointLeft = newProbePoint
        newProbeSegment2.ringProbePointRight = newProbePoint.neighborRight
        newProbePoint.neighborLeft.ringProbeSegmentRight = newProbeSegment1
        newProbePoint.neighborRight.ringProbeSegmentLeft = newProbeSegment2
        newProbePoint.ringProbeSegmentLeft = newProbeSegment1
        newProbePoint.ringProbeSegmentRight = newProbeSegment2
        
        newProbePoint.isMelded = true
        
        for ringProbeSegmentIndex in 0..<temp_1_ringProbeSegmentCount {
            let ringProbeSegment = temp_1_ringProbeSegments[ringProbeSegmentIndex]
            partsFactory.depositRingProbeSegment(ringProbeSegment)
            ringProbeSegmentBucket.remove(ringProbeSegment: ringProbeSegment)
        }
        
        for ringProbePointIndex in 0..<temp_1_ringProbePointCount {
            let ringProbePoint = temp_1_ringProbePoints[ringProbePointIndex]
            partsFactory.depositRingProbePoint(ringProbePoint)
        }
        
        return true
    }
}
