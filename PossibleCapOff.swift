//
//  PossibleCapOff.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 2/14/24.
//

import Foundation

class PossibleCapOff: PointProtocol {
    
    typealias Point = Math.Point
    
    var x: Float = 0.0
    var y: Float = 0.0
    
    var point: Point {
        Point(x: x,
              y: y)
    }
    
}
