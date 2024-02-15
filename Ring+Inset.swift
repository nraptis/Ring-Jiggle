//
//  Ring+SexyTriangulate.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/31/23.
//

import Foundation

extension Ring {

    //@Precondition: attemptCalculateBasicsAndDetermineSafetyPartA passed check
    //@Precondition: attemptCalculateBasicsAndDetermineSafetyPartB passed check
    //@Precondition: buildRingPointInsidePolygonBucket
    //@Precondition: buildLineSegmentBucket
    
    func attemptInset(needsContentions: Bool) -> Bool {
    
        calculateLineSegmentThreats(needsContentions: needsContentions)
        
        calculateProbeSegmentsForInitialInset()
        calculatePointCornerOutliers()
        
        calculateProbePointsFromColliders()
        
        calculateProbeSegmentsUsingProbePoints()
        buildRingProbeSegmentBucket()
        
        if !attemptMeldAndRelax() {
            return false
        }
        
        
        /*
        if POLY_MESH_MONO_MELD_COMPLEX_ENABLED {
            
            if depth == POLY_MESH_MONO_MELD_COMPLEX_LEVEL {
                if !attemptToRelaxIllegalProbePointGeometry() {
                    return false
                }
            } else {
                print("A Skipping relax step...")
                //return false
            }
        } else {
            if POLY_MESH_OMNI_MELD_COMPLEX_ENABLED && (depth <= POLY_MESH_OMNI_MELD_COMPLEX_LEVEL) {
                if !attemptToRelaxIllegalProbePointGeometry() {
                    return false
                }
            } else {
                print("B Skipping relax step...")
                //return false
            }
        }
        */
        
        
        //applyProbePointTriangulation()
        if POLY_MESH_INSET_ENABLED {
            purgeSubrings()
            if (depth < POLY_MESH_INSET_LEVEL) || (POLY_MESH_INSET_LEVEL < 0) {
                if ringProbePointCount > 0 {
                    let subring = partsFactory.withdrawRing(polyMesh: polyMesh)
                    
                    subring.addPointsBegin(depth: depth + 1)
                    for ringProbePointIndex in 0..<ringProbePointCount {
                        let ringProbePoint = ringProbePoints[ringProbePointIndex]
                        subring.addPoint(ringProbePoint.x,
                                         ringProbePoint.y)
                    }
                    
                    if !subring.attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
                        partsFactory.depositRing(subring)
                        return false
                    }
                    
                    if !subring.attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true,
                                                                              needsLineSegmentBucket: true,
                                                                              test: false) {
                        partsFactory.depositRing(subring)
                        return false
                    }
                    
                    for ringProbePointIndex in 0..<ringProbePointCount {
                        let ringProbePoint = ringProbePoints[ringProbePointIndex]
                        let newRingPoint = subring.ringPoints[ringProbePointIndex]
                        newRingPoint.connectionCount = 0
                        for connectionIndex in 0..<ringProbePoint.connectionCount {
                            let connection = ringProbePoint.connections[connectionIndex]
                            newRingPoint.addConnection(connection)
                        }
                        ringProbePoint.connectionCount = 0
                    }
                    
                    
                    for ringPointIndex in 0..<ringPointCount {
                        let ringPoint = ringPoints[ringPointIndex]
                        ringPoint.purgePossibleSplits(partsFactory: partsFactory)
                        ringPoint.purgeLineSegmentContentions(partsFactory: partsFactory)
                    }
                    
                    purgeLineSegments()
                    purgeProbePoints()
                    purgeProbeSegments()
                    ringProbeSegmentBucket.reset()
                    ringLineSegmentBucket.reset()
                    ringPointInsidePolygonBucket.reset()
                    
                    addSubring(subring)
                    return true
                }
            }
        }
        
        return false
    }
}
