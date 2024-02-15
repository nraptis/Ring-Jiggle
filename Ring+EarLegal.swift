//
//  Ring+EarLegal.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/12/24.
//

import Foundation

extension Ring {
    
    func measureEarLegal(index: Int) -> Bool {
        
        if index < 0 || index >= ringPointCount {
            print("[JNYYH5] index1 \(index) out of range \(ringPointCount)")
            return false
        }
        
        if ringPointCount < 4 {
            print("[JNYYH6] ringPointCount \(ringPointCount) < 4")
            return false
        }
        
        let ringPointCount1 = ringPointCount - 1
        
        var index1 = index - 1
        if index1 == -1 {
            index1 = ringPointCount1
        }
        
        var index2 = index + 1
        if index2 == ringPointCount {
            index2 = 0
        }
        
        
        let splitRingPoint1 = ringPoints[index1]
        let splitRingPoint2 = ringPoints[index2]
        
        preComputedLineSegment1.x1 = splitRingPoint1.x
        preComputedLineSegment1.y1 = splitRingPoint1.y
        preComputedLineSegment1.x2 = splitRingPoint2.x
        preComputedLineSegment1.y2 = splitRingPoint2.y
        
        preComputedLineSegment1.precompute()
        
        let minIndex = min(index1, index2)
        let maxIndex = max(index1, index2)
        
        if !measureEarLegalComplexHelper(index: index) {
            return false
        }
    
        if !measureEarLegalClockwiseHelper(index: index) {
            return false
        }
    
        if !measureEarLegalPointClosenessNeighborHelper(index1: minIndex, index2: maxIndex) {
            return false
        }
    
        if !measureEarLegalPointClosenessDistantHelper(index1: index1, index2: index2) {
        
            return false
        }
        
        return true
    }
    
}
