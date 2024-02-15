//
//  Ring+MeldCheckWedgeTooClose.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/29/24.
//

import Foundation

extension Ring {
    
    func calculateMeldsFromPossibleMeldsRayWedgeTooClose(meldProbePointBeforeFirst: RingProbePoint,
                                                         meldProbePointAfterLast: RingProbePoint) -> Bool {
        if meldProbePointAfterLast.connectionCount > 0 {
            let meldProbeConnectionFirstAfterLast = meldProbePointAfterLast.connections[0]
            preComputedLineSegment3.x1 = meldProbeConnectionFirstAfterLast.x
            preComputedLineSegment3.y1 = meldProbeConnectionFirstAfterLast.y
            preComputedLineSegment3.x2 = meldProbePointAfterLast.x
            preComputedLineSegment3.y2 = meldProbePointAfterLast.y
            preComputedLineSegment3.precompute()
            if preComputedLineSegment3.distanceSquaredToLineSegment(preComputedLineSegment1) < PolyMeshConstants.meldGeometryTooCloseSquared {
                if DEBUG_MELD {
                    print("[Real] A: Wedge Too Close")
                }
                return false
            }
        } else {
            print("[Real] Why ABC A: ???")
            return false
        }
        
        if meldProbePointBeforeFirst.connectionCount > 0 {
            let meldProbeConnectionLastAfterFirst = meldProbePointBeforeFirst.connections[meldProbePointBeforeFirst.connectionCount - 1]
            preComputedLineSegment4.x1 = meldProbeConnectionLastAfterFirst.x
            preComputedLineSegment4.y1 = meldProbeConnectionLastAfterFirst.y
            preComputedLineSegment4.x2 = meldProbePointBeforeFirst.x
            preComputedLineSegment4.y2 = meldProbePointBeforeFirst.y
            preComputedLineSegment4.precompute()
            if preComputedLineSegment4.distanceSquaredToLineSegment(preComputedLineSegment2) < PolyMeshConstants.meldGeometryTooCloseSquared {
                if DEBUG_MELD {
                    print("[Real] B: Wedge Too Close")
                }
                return false
            }
        } else {
            print("[Real] Why ABC B: ???")
            return false
        }
        
        return true
    }
}
