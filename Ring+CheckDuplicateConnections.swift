//
//  Ring+CheckDuplicateConnections.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/30/24.
//

import Foundation

extension Ring {
    
    func doProbePointsContainDuplicateConnections() {
        
        
        for ringProbePointIndex in 0..<ringProbePointCount {
            
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
        
            for connectionIndex1 in 0..<ringProbePoint.connectionCount {
                let connection1 = ringProbePoint.connections[connectionIndex1]
                
                for connectionIndex2 in 0..<ringProbePoint.connectionCount {
                    let connection2 = ringProbePoint.connections[connectionIndex2]
                    
                    if connectionIndex1 == connectionIndex2 { continue }
                    
                    if connection1 === connection2 {
                        print("[Never], 2 Same Con BOOF!!!")
                    }
                }
            }
        }
    }
}
