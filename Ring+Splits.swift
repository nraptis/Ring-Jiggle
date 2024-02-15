//
//  Ring+SplitCalculate.swift
//  Jiggle3
//
//  Created by Nick "The Fallen" Raptis on 2/11/24.
//

import Foundation

extension Ring {
    
    func calculateRingSplitsAndExecuteInstantSplitIfExists() -> Bool {
        
        if POLY_MESH_MONO_SPLIT_ENABLED {
            if depth == POLY_MESH_MONO_SPLIT_LEVEL {
                
            } else {
                return false
            }
        } else {
            if POLY_MESH_OMNI_SPLIT_ENABLED && (depth <= POLY_MESH_OMNI_SPLIT_LEVEL) {
                
            } else {
                return false
            }
        }
        
        for possibleSplitPairIndex in 0..<possibleSplitPairCount {
            let possibleSplitPair = possibleSplitPairs[possibleSplitPairIndex]
            
            var point1 = possibleSplitPair.ringPoint1.point
            var point2 = possibleSplitPair.ringPoint2.point
            point1 = polyMesh.transformPoint(point: point1)
            point2 = polyMesh.transformPoint(point: point2)
            
            if attemptMeasureSplitQuality(index1: possibleSplitPair.ringPoint1.ringIndex,
                                               index2: possibleSplitPair.ringPoint2.ringIndex,
                                               quality: &tempRingSplitQuality) {
                
                if tempRingSplitQuality.isInstantSplit {
                    let splitPointCount = getSplitPointCount(index1: possibleSplitPair.ringPoint1.ringIndex,
                                                                  index2: possibleSplitPair.ringPoint2.ringIndex)
                    
                    let splitRing1 = partsFactory.withdrawRing(polyMesh: polyMesh)
                    let splitRing2 = partsFactory.withdrawRing(polyMesh: polyMesh)
                    
                    if split(splitRing1: splitRing1,
                             splitRing2: splitRing2,
                             index1: possibleSplitPair.ringPoint1.ringIndex,
                             index2: possibleSplitPair.ringPoint2.ringIndex, count: splitPointCount) {
                        
                        addSubring(splitRing1)
                        addSubring(splitRing2)
                        return true
                    } else {
                        print("[LQBT87] Never Happen? We thought we could split, we did, something is askew!!!")
                        partsFactory.depositRing(splitRing1)
                        partsFactory.depositRing(splitRing2)
                    }
                } else {
                    let ringSplit = partsFactory.withdrawRingSplit()
                    ringSplit.index1 = possibleSplitPair.ringPoint1.ringIndex
                    ringSplit.index2 = possibleSplitPair.ringPoint2.ringIndex
                    ringSplit.splitQuality = tempRingSplitQuality
                    addRingSplit(ringSplit)
                }
                
                /*
                let ringSplit = partsFactory.withdrawRingSplit()
                ringSplit.index1 = possibleSplitPair.ringPoint1.ringIndex
                ringSplit.index2 = possibleSplitPair.ringPoint2.ringIndex
                ringSplit.splitQuality = tempRingSplitQuality
                addRingSplit(ringSplit)
                */
                
            }
        }
        return false
    }
    
    func executeBestSplitPossible() -> Bool {
        
        if POLY_MESH_MONO_SPLIT_ENABLED {
            if depth == POLY_MESH_MONO_SPLIT_LEVEL {
                
            } else {
                return false
            }
        } else {
            if POLY_MESH_OMNI_SPLIT_ENABLED && (depth <= POLY_MESH_OMNI_SPLIT_LEVEL) {
                
            } else {
                return false
            }
        }
        
        var numberTried = 0
        let originalCount = ringSplits.count
        while ringSplits.count > 0 {
            if let bestRingSplit = getBestRingSplit() {
                numberTried += 1
             
                let splitRing1 = partsFactory.withdrawRing(polyMesh: polyMesh)
                let splitRing2 = partsFactory.withdrawRing(polyMesh: polyMesh)
                
                let splitPointCount = getSplitPointCount(index1: bestRingSplit.index1,
                                                         index2: bestRingSplit.index2)
                
                if split(splitRing1: splitRing1,
                         splitRing2: splitRing2,
                         index1: bestRingSplit.index1,
                         index2: bestRingSplit.index2,
                         count: splitPointCount) {
                    
                    addSubring(splitRing1)
                    addSubring(splitRing2)
                    
                    //print("Split \(ObjectIdentifier(self)) into \(ObjectIdentifier(splitRing1)) and \(ObjectIdentifier(splitRing2)))")
                    
                    return true
                } else {
                    //print("[LQBG88] We are trying splits, and one boofed...!!!")
                    
                    partsFactory.depositRing(splitRing1)
                    partsFactory.depositRing(splitRing2)
                    
                    removeRingSplit(bestRingSplit)
                }
                
            } else {
                return false
            }
        }
        
        if numberTried > 5 {
            print("tried \(numberTried) splits..., had \(originalCount) to try...")
        }
        
        return false
    }
}
