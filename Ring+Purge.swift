//
//  Ring+Purge.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/7/24.
//

import Foundation

extension Ring {
    
    func purgeRingPoints() {
        for ringPointIndex in 0..<ringPointCount {
            partsFactory.depositRingPoint(ringPoints[ringPointIndex])
        }
        ringPointCount = 0
    }
    
    func purgeLineSegments() {
        for ringLineSegmentIndex in 0..<ringLineSegmentCount {
            partsFactory.depositRingLineSegment(ringLineSegments[ringLineSegmentIndex])
        }
        ringLineSegmentCount = 0
    }
    
    func purgeProbePoints() {
        for ringProbePointIndex in 0..<ringProbePointCount {
            partsFactory.depositRingProbePoint(ringProbePoints[ringProbePointIndex])
        }
        ringProbePointCount = 0
    }
    
    func purgeProbeSegments() {
        for ringProbeSegmentIndex in 0..<ringProbeSegmentCount {
            partsFactory.depositRingProbeSegment(ringProbeSegments[ringProbeSegmentIndex])
        }
        ringProbeSegmentCount = 0
    }
    
    func purgePossibleSplitPairs() {
        for possibleSplitPairIndex in 0..<possibleSplitPairCount {
            let possibleSplitPair = possibleSplitPairs[possibleSplitPairIndex]
            partsFactory.depositPossibleSplitPair(possibleSplitPair)
        }
        possibleSplitPairCount = 0
    }
    
    func purgeRingSplits() {
        for ringSplitIndex in 0..<ringSplitCount {
            let ringSplit = ringSplits[ringSplitIndex]
            partsFactory.depositRingSplit(ringSplit)
        }
        ringSplitCount = 0
    }
    
    
    func purgeSweepLines() {
        for sweepLinesIndex in sweepLines.indices {
            let sweepLine = sweepLines[sweepLinesIndex]
            partsFactory.depositRingSweepLine(sweepLine)
        }
        sweepLines.removeAll(keepingCapacity: true)
    }
    
    func purgeSweepCollisionBucket() {
        for sweepCollisionBucketIndex in sweepCollisionBucket.indices {
            for sweepLineLineCollisionIndex in sweepCollisionBucket[sweepCollisionBucketIndex].indices {
                let sweepLineLineCollision = sweepCollisionBucket[sweepCollisionBucketIndex][sweepLineLineCollisionIndex]
                partsFactory.depositRingSweepCollision(sweepLineLineCollision)
            }
            sweepCollisionBucket[sweepCollisionBucketIndex].removeAll(keepingCapacity: true)
        }
    }
    
    func purgePossibleMelds() {
        for possibleMeldIndex in 0..<possibleMeldCount {
            let possibleMeld = possibleMelds[possibleMeldIndex]
            partsFactory.depositPossibleMeld(possibleMeld)
        }
        possibleMeldCount = 0
    }
    
    func purgeRingMelds() {
        for ringMeldIndex in 0..<ringMeldCount {
            let ringMeld = ringMelds[ringMeldIndex]
            partsFactory.depositRingMeld(ringMeld)
        }
        ringMeldCount = 0
    }
    
    func purgePossibleCapOffs() {
        for possibleCapOffIndex in 0..<possibleCapOffCount {
            let possibleCapOff = possibleCapOffs[possibleCapOffIndex]
            partsFactory.depositPossibleCapOff(possibleCapOff)
        }
        possibleCapOffCount = 0
    }
    
    func purgeMeldProbeSpokes() {
        for meldProbeSpokeIndex in 0..<meldProbeSpokeCount {
            let meldProbeSpoke = meldProbeSpokes[meldProbeSpokeIndex]
            partsFactory.depositRingProbeSpoke(meldProbeSpoke)
        }
        meldProbeSpokeCount = 0
    }
    
    /*
    func purgeAllSavedProbePoints() {
        for ringProbePointIndex in 0..<savedRingProbePointCount {
            let ringProbePoint = savedRingProbePoints[ringProbePointIndex]
            partsFactory.depositRingProbePoint(ringProbePoint)
        }
        savedRingProbePointCount = 0
    }
    */
}
