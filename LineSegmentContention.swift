//
//  LineSegmentContention.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/29/23.
//

import Foundation

class LineSegmentContention {
    unowned var ringLineSegment: RingLineSegment!
    var distanceSquared: Float = 0.0
}


class ProbeSegmentContention {
    unowned var ringProbeSegment: RingProbeSegment!
    var distanceSquared: Float = 0.0
    var isDistant = false
}
