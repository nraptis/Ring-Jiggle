//
//  Ring+ContainsPoint.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/6/24.
//

import Foundation

extension Ring {
    
    func containsRingPoint(_ x: Float, _ y: Float) -> Bool {
        ringPointInsidePolygonBucket.query(x: x,
                              y: y)
    }
    
    func containsRingPoint(_ point: Point) -> Bool {
        ringPointInsidePolygonBucket.query(x: point.x,
                              y: point.y)
    }
    
    /*
    func containsProbePoint(_ x: Float, _ y: Float) -> Bool {
        probePointInsidePolygonBucket.query(x: x,
                                            y: y)
    }
    
    func containsProbePoint(_ point: Point) -> Bool {
        probePointInsidePolygonBucket.query(x: point.x,
                                            y: point.y)
    }
    */
    
}
