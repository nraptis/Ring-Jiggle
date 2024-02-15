//
//  Ring+SweepLine.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/4/23.
//

import Foundation

extension Ring {
    
    func getTargetSweepLineCount() -> Int {
        
        let minY = getMinY() - 1.0
        let maxY = getMaxY() + 1.0
        let spanY = (maxY - minY)
        let proposedLineCount = Int((spanY / polyMeshConstants.meshSplitDistance) + 0.5)
        if proposedLineCount < 3 {
            return 3
        } else {
            return proposedLineCount
        }
    }
    
    func calculateHorizontalSweepLines(_ count: Int) {
        for sweepCollisionBucketIndex in sweepCollisionBucket.indices {
            for sweepLineLineCollisionIndex in sweepCollisionBucket[sweepCollisionBucketIndex].indices {
                let sweepLineLineCollision = sweepCollisionBucket[sweepCollisionBucketIndex][sweepLineLineCollisionIndex]
                partsFactory.depositRingSweepCollision(sweepLineLineCollision)
            }
            sweepCollisionBucket[sweepCollisionBucketIndex].removeAll(keepingCapacity: true)
        }
        while sweepCollisionBucket.count < count {
            sweepCollisionBucket.append([RingSweepCollision]())
        }
        for sweepLineHorizontalIndex in sweepLines.indices {
            let sweepLine = sweepLines[sweepLineHorizontalIndex]
            partsFactory.depositRingSweepLine(sweepLine)
        }
        sweepLines.removeAll(keepingCapacity: true)
        //for sweepSegmentBucketIndex in sweepSegmentBucket.indices {
        //    sweepSegmentBucket[sweepSegmentBucketIndex].removeAll(keepingCapacity: true)
        //}
        purgeAllSweepSegmentBucketContents()
        
        while sweepSegmentBucket.count < count {
            sweepSegmentBucket.append([RingLineSegment]())
        }
        let minX = getMinX() - 1.0
        let minY = getMinY() - 1.0
        let maxY = getMaxY() + 1.0
        var yIndex = 0
        let count1f = Float(count + 1)
        while yIndex < count {
            let percent = Float(yIndex + 1) / count1f
            let y = minY + (maxY - minY) * percent
            for ringLineSegmentIndex in 0..<ringLineSegmentCount {
                let ringLineSegment = ringLineSegments[ringLineSegmentIndex]
                if Math.rangesContainsValue(start: ringLineSegment.y1,
                                            end: ringLineSegment.y2,
                                            value: y) {
                    sweepSegmentBucket[yIndex].append(ringLineSegment)
                }
            }
            yIndex += 1
        }
        
        yIndex = 0
        while yIndex < count {
            let percent = Float(yIndex + 1) / count1f
            let y = minY + (maxY - minY) * percent
            let planeOrigin = Point(x: minX, y: y)
            let planeDirection = Vector(x: 1.0, y: 0.0)
            for ringLineSegmentIndex in sweepSegmentBucket[yIndex].indices {
                let ringLineSegment = sweepSegmentBucket[yIndex][ringLineSegmentIndex]
                let rayRayResult = Math.rayIntersectionRay(rayOrigin1X: ringLineSegment.x1, rayOrigin1Y: ringLineSegment.y1,
                                                           rayNormal1X: ringLineSegment.normalX, rayNormal1Y: ringLineSegment.normalY,
                                                           rayOrigin2X: minX, rayOrigin2Y: y,
                                                           rayDirection2X: 1.0, rayDirection2Y: 0.0)
                switch rayRayResult {
                case .invalidCoplanar:
                    break
                case .valid(let pointX, let pointY, _):
                    let collision = partsFactory.withdrawRingSweepCollision()
                    collision.ringLineSegment = ringLineSegment
                    collision.x = pointX
                    collision.y = pointY
                    sweepCollisionBucket[yIndex].append(collision)
                }
            }
            
            //TODO: Sort in place
            sweepCollisionBucket[yIndex].sort { lhs, rhs in
                lhs.x < rhs.x
            }
            
            yIndex += 1
        }
        
        buildRingPointInsidePolygonBucket()
        
        yIndex = 0
        while yIndex < count {
            let percent = Float(yIndex + 1) / count1f
            let y = minY + (maxY - minY) * percent
            var previousIndex = 0
            var currentIndex = 1
            let sweepLine = partsFactory.withdrawRingSweepLine()
            sweepLines.append(sweepLine)
            sweepLine.y = y
            if (sweepCollisionBucket[yIndex].count % 2) == 0 {
                while currentIndex < sweepCollisionBucket[yIndex].count {
                    let collision1 = sweepCollisionBucket[yIndex][previousIndex]
                    let collision2 = sweepCollisionBucket[yIndex][currentIndex]
                    let sweepSegment = partsFactory.withdrawRingSweepSegment()
                    sweepSegment.x1 = collision1.x
                    sweepSegment.x2 = collision2.x
                    sweepSegment.y = y
                    sweepSegment.ringLineSegmentLeft = collision1.ringLineSegment
                    sweepSegment.ringLineSegmentRight = collision2.ringLineSegment
                    
                    sweepLine.segments.append(sweepSegment)
                    previousIndex += 2
                    currentIndex += 2
                }
            } else {
                while currentIndex < sweepCollisionBucket[yIndex].count {
                    let collision1 = sweepCollisionBucket[yIndex][previousIndex]
                    let collision2 = sweepCollisionBucket[yIndex][currentIndex]
                    let midPoint = Point(x: (collision1.x + collision2.x) * 0.5,
                                         y: collision1.y)
                    if containsRingPoint(midPoint) {
                        let sweepSegment = partsFactory.withdrawRingSweepSegment()
                        sweepSegment.x1 = collision1.x
                        sweepSegment.x2 = collision2.x
                        sweepSegment.y = y
                        sweepLine.segments.append(sweepSegment)
                        previousIndex += 2
                        currentIndex += 2
                    } else {
                        print("This should not happen, something is fishy... (mismatching sweeps)")
                        previousIndex += 1
                        currentIndex += 1
                    }
                }
            }
            yIndex += 1
        }
    }
    
    func calculateHorizontalSweepPoints(_ count: Int) {
        //for sweepSegmentBucketIndex in sweepSegmentBucket.indices {
        //    sweepSegmentBucket[sweepSegmentBucketIndex].removeAll(keepingCapacity: true)
        //}
        
        let pointTooClose = PolyMeshConstants.meshPointTooClose
        let pointTooCloseSquared = pointTooClose * pointTooClose
        
        purgeAllSweepSegmentBucketContents()
        
        while sweepSegmentBucket.count < count {
            sweepSegmentBucket.append([RingLineSegment]())
        }
        let minY = getMinY() - 1.0
        let maxY = getMaxY() + 1.0
        let tooClosePadding = (pointTooClose + pointTooClose)
        var yIndex = 0
        let count1f = Float(count + 1)
        while yIndex < count {
            let percent = Float(yIndex + 1) / count1f
            let y = minY + (maxY - minY) * percent
            let rangeY1 = y - tooClosePadding
            let rangeY2 = y + tooClosePadding
            for ringLineSegmentIndex in 0..<ringLineSegmentCount {
                let ringLineSegment = ringLineSegments[ringLineSegmentIndex]
                if Math.rangesOverlap(start1: ringLineSegment.y1,
                                      end1: ringLineSegment.y2,
                                      start2: rangeY1,
                                      end2: rangeY2) {
                    sweepSegmentBucket[yIndex].append(ringLineSegment)
                }
            }
            yIndex += 1
        }
        
        for sweepLineIndex in sweepLines.indices {
            let sweepLine = sweepLines[sweepLineIndex]
            for sweepSegmentIndex in sweepLine.segments.indices {
                let sweepSegment = sweepLine.segments[sweepSegmentIndex]
                let segmentLength = sweepSegment.x2 - sweepSegment.x1
                let proposedPointCount = Int((segmentLength / polyMeshConstants.meshSplitDistance) + 0.5)
                let proposedPointCount1f = Float(proposedPointCount + 1)
                var didAnyPointGetUsed = false
                var pointIndex = 0
                while pointIndex < proposedPointCount {
                    let percent = Float(pointIndex + 1) / proposedPointCount1f
                    let x = sweepSegment.x1 + (segmentLength) * percent
                    let y = sweepLine.y
                    var isSafePoint = true
                    for ringLineSegmentIndex in sweepSegmentBucket[sweepLineIndex].indices {
                        let ringLineSegment = sweepSegmentBucket[sweepLineIndex][ringLineSegmentIndex]
                        let distanceSquared = ringLineSegment.distanceSquaredToPoint(Point(x: x, y: y))
                        if distanceSquared < pointTooCloseSquared {
                            isSafePoint = false
                            break
                        }
                    }
                    if isSafePoint {
                        let sweepPoint = partsFactory.withdrawRingSweepPoint()
                        sweepPoint.x = x
                        sweepPoint.y = sweepLine.y
                        sweepSegment.points.append(sweepPoint)
                        didAnyPointGetUsed = true
                    }
                    pointIndex += 1
                }
                
                // We might be a stubber, in which case, try middle point
                if didAnyPointGetUsed == false {
                    let x = sweepSegment.x1 + (segmentLength) * 0.5
                    let y = sweepLine.y
                    var isSafePoint = true
                    for ringLineSegmentIndex in sweepSegmentBucket[sweepLineIndex].indices {
                        let ringLineSegment = sweepSegmentBucket[sweepLineIndex][ringLineSegmentIndex]
                        let distanceSquared = ringLineSegment.distanceSquaredToPoint(Point(x: x, y: y))
                        if distanceSquared < pointTooCloseSquared {
                            isSafePoint = false
                            break
                        }
                    }
                    if isSafePoint {
                        let sweepPoint = partsFactory.withdrawRingSweepPoint()
                        sweepPoint.x = x
                        sweepPoint.y = sweepLine.y
                        sweepSegment.points.append(sweepPoint)
                    }
                }
            }
        }
    }
    
    func purgeAllSweepSegmentBucketContents() {
        for sweepSegmentBucketIndex in sweepSegmentBucket.indices {
            sweepSegmentBucket[sweepSegmentBucketIndex].removeAll(keepingCapacity: true)
        }
    }
    
    
    /*
    for sweepLinesIndex in ring.sweepLines.indices {
        let sweepLineHorizontal = ring.sweepLines[sweepLinesIndex]
        depositRingSweepLine(sweepLineHorizontal)
    }
    ring.sweepLines.removeAll(keepingCapacity: true)
    
    for sweepCollisionBucketIndex in ring.sweepCollisionBucket.indices {
        for sweepLineLineCollisionIndex in ring.sweepCollisionBucket[sweepCollisionBucketIndex].indices {
            let sweepLineLineCollision = ring.sweepCollisionBucket[sweepCollisionBucketIndex][sweepLineLineCollisionIndex]
            depositRingSweepCollision(sweepLineLineCollision)
        }
        ring.sweepCollisionBucket[sweepCollisionBucketIndex].removeAll(keepingCapacity: true)
    }
    */
}
