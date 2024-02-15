//
//  Ring+ProbePointsTagContentions.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/1/24.
//

import Foundation

extension Ring {
    
    /*
    func calculateLargestStreakUsingLeftAndRightContentions() -> Int {
        calculateMeldStreaks(numberOfPointsToMeld: PolyMeshConstants.meldMaxSteps)
        var result = 0
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            if ringProbePoint.meldStreak > result {
                result = ringProbePoint.meldStreak
            }
        }
        return result
    }
    
    func calculateTagsUsingLeftAndRightContentions(numberOfPointsToMeld: Int) -> Bool {
        
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            ringProbePoint.isTagged = false
        }
        
        if numberOfPointsToMeld < 2 {
            print("FATAL: [FR56] numberOfPointsToMeld should be 2 or more, you put \(numberOfPointsToMeld)")
            return false
        }
        if ringProbePointCount < 2 {
            return false
        }
        
        calculateMeldStreaks(numberOfPointsToMeld: numberOfPointsToMeld)
        
        var result = false
        let numberOfPointsToMeld1 = numberOfPointsToMeld - 1
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            if ringProbePoint.meldStreak >= numberOfPointsToMeld1 {
                ringProbePoint.isTagged = true
                result = true
            }
        }
        return result
    }
    
    private func calculateMeldStreaks(numberOfPointsToMeld: Int) {
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            ringProbePoint.meldStreak = 0
        }
        
        // What does streak mean? It means exactly this.
        // 1.) WE CONTEND RIGHT
        // 2.) There are exactly N that content LEFT immediately following
        // 3.) That's it, the whole thing... I'm sure we will find edge cases where this
        //     was not enough... We cannot be TOO LIBERAL about melding either... It's gotta be Tun'd JR
        
        if ringProbePointCount <= 0 {
            return
        }
        
        var streakCount = 0
        
        var index = numberOfPointsToMeld
        if index >= ringProbePointCount {
            index = ringProbePointCount - 1
        }
        
        
        while index >= 0 {
            if ringProbePoints[index].isContendingRight {
                streakCount += 1
            } else {
                streakCount = 0
            }
            index -= 1
        }
        
        index = ringProbePointCount - 1
        while index >= 0 {
            let ringProbePoint = ringProbePoints[index]
            if ringProbePoint.isContendingRight {
                streakCount += 1
            } else {
                streakCount = 0
            }
            ringProbePoint.meldStreak = streakCount
            index -= 1
        }
    }
    */
    
}
