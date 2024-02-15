//
//  Ring+EarClipping.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/29/23.
//

import Foundation

extension Ring {
    
    func attemptToClipEar() -> Bool {
        
        if ringPointCount <= 3 {
            return false
        }
        
        if POLY_MESH_MONO_EARS_ENABLED {
            if depth == POLY_MESH_MONO_EARS_LEVEL {
            } else {
                return false
            }
        } else {
            if POLY_MESH_OMNI_EARS_ENABLED && (depth <= POLY_MESH_OMNI_EARS_LEVEL) {
                
            } else {
                return false
            }
        }
        
        var bestEarIndex = -1
        var worstEarAngle = Float(100_000_000.0)
        for ringPointIndex in 0..<ringPointCount {
            let ringPoint = ringPoints[ringPointIndex]
            if ringPoint.angularSpan < PolyMeshConstants.earClipThreshold {
                if measureEarLegal(index: ringPointIndex) {
                    if ringPoint.angularSpan < worstEarAngle {
                        worstEarAngle = ringPoint.angularSpan
                        bestEarIndex = ringPointIndex
                    }
                }
            }
        }
        
        guard bestEarIndex != -1 else {
            return false
        }
        
        var ringPointIndexPrevious = bestEarIndex - 1
        if ringPointIndexPrevious < 0 { ringPointIndexPrevious = ringPointCount - 1 }
        
        var ringPointIndexNext = bestEarIndex + 1
        if ringPointIndexNext == ringPointCount { ringPointIndexNext = 0 }
        
        let ringPointEar = ringPoints[bestEarIndex]
        
        //let ringPointEar = partsFactory.withdrawRingPoint()
        //ringPointEar.x = ringPointEarOriginal.x
        //ringPointEar.y = ringPointEarOriginal.y
        //ringPointEar.triangleIndex = polyMesh.meshVertexIndex
        //ringPointEar.refreshMeshPoint()
        //polyMesh.meshVertexIndex += 1
        
        //polyMesh.addRingPoint(ringPointPrevious)
        
        
        var numberOfPointsForSplit = getSplitPointCount(index1: ringPointIndexPrevious, index2: ringPointIndexNext)
        //numberOfPointsForSplit = 0
        
        if numberOfPointsForSplit == 1 {
        //    numberOfPointsForSplit = 2
        }
        
        /*
        if TOOL_POINT_NORMALS_LEVEL == 0 {
            numberOfPointsForSplit = 0
        } else {
            if numberOfPointsForSplit == 1 {
                numberOfPointsForSplit = 2
            }
        }
        */
        
        if numberOfPointsForSplit == 0 {

            _ = earClipReplaceRingPointZeroRingPoints(ringPointIndex: bestEarIndex)
            
            // In this case, we are point 0
            if ringPointIndexPrevious == ringPointCount {
                // Point at the tail.
                ringPointIndexPrevious = ringPointCount - 1
            }
            
            // In this case, we were the tail.
            if bestEarIndex == ringPointCount {
                // Point at 0.
                ringPointIndexNext = 0
            } else {
                // Since we lost a point, the "next" is now "current"
                ringPointIndexNext = bestEarIndex
            }
            
            let originalRingPoint1 = ringPoints[ringPointIndexPrevious]
            let originalRingPoint2 = ringPoints[ringPointIndexNext]
            
            let ringPoint1 = partsFactory.withdrawRingPoint()
            ringPoint1.x = originalRingPoint1.x
            ringPoint1.y = originalRingPoint1.y
            ringPoint1.triangleIndex = polyMesh.meshVertexIndex
            ringPoint1.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint2 = partsFactory.withdrawRingPoint()
            ringPoint2.x = originalRingPoint2.x
            ringPoint2.y = originalRingPoint2.y
            ringPoint2.triangleIndex = polyMesh.meshVertexIndex
            ringPoint2.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            
            let polyMeshTriangle = partsFactory.withdrawPolyMeshTriangle()
            
            polyMeshTriangle.type = .test1
            
            polyMeshTriangle.meshPoint1 = ringPoint1.meshPoint
            polyMeshTriangle.meshPoint2 = ringPointEar.meshPoint
            polyMeshTriangle.meshPoint3 = ringPoint2.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle)
            
            polyMesh.addRingPoint(ringPoint1)
            polyMesh.addRingPoint(ringPoint2)
            polyMesh.addRingPoint(ringPointEar)
            
            return true
        } else if numberOfPointsForSplit == 1 {
            
            _ = earClipReplaceRingPointOneRingPoint(ringPointIndex: bestEarIndex)
            
            let originalRingPoint1 = ringPoints[ringPointIndexPrevious]
            let originalRingPoint2 = ringPoints[bestEarIndex]
            let originalRingPoint3 = ringPoints[ringPointIndexNext]
            
            let ringPoint1 = partsFactory.withdrawRingPoint()
            ringPoint1.x = originalRingPoint1.x
            ringPoint1.y = originalRingPoint1.y
            ringPoint1.triangleIndex = polyMesh.meshVertexIndex
            ringPoint1.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint2 = partsFactory.withdrawRingPoint()
            ringPoint2.x = originalRingPoint2.x
            ringPoint2.y = originalRingPoint2.y
            ringPoint2.triangleIndex = polyMesh.meshVertexIndex
            ringPoint2.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint3 = partsFactory.withdrawRingPoint()
            ringPoint3.x = originalRingPoint3.x
            ringPoint3.y = originalRingPoint3.y
            ringPoint3.triangleIndex = polyMesh.meshVertexIndex
            ringPoint3.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let polyMeshTriangle1 = partsFactory.withdrawPolyMeshTriangle()
            polyMeshTriangle1.type = .test5
            polyMeshTriangle1.meshPoint1 = ringPoint1.meshPoint
            polyMeshTriangle1.meshPoint2 = ringPoint2.meshPoint
            polyMeshTriangle1.meshPoint3 = ringPointEar.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle1)
            
            let polyMeshTriangle2 = partsFactory.withdrawPolyMeshTriangle()
            polyMeshTriangle2.type = .test6
            polyMeshTriangle2.meshPoint1 = ringPoint2.meshPoint
            polyMeshTriangle2.meshPoint2 = ringPoint3.meshPoint
            polyMeshTriangle2.meshPoint3 = ringPointEar.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle2)
            
            polyMesh.addRingPoint(ringPoint1)
            polyMesh.addRingPoint(ringPoint2)
            polyMesh.addRingPoint(ringPoint3)
            polyMesh.addRingPoint(ringPointEar)
            
            return true
            
        } else {
            
            // In this case, we are point 0
            _ = earClipReplaceRingPointTwoRingPoints(ringPointIndex: bestEarIndex)
            
            if ringPointIndexPrevious == (ringPointCount - 2) {
                // Point at the tail.
                ringPointIndexPrevious = ringPointCount - 1
            }
            
            var ringPointIndexNextNext = bestEarIndex + 2
            if ringPointIndexNextNext >= ringPointCount {
                ringPointIndexNextNext -= ringPointCount
            }
            
            let originalRingPoint1 = ringPoints[ringPointIndexPrevious]
            let originalRingPoint2 = ringPoints[bestEarIndex]
            let originalRingPoint3 = ringPoints[bestEarIndex + 1]
            let originalRingPoint4 = ringPoints[ringPointIndexNextNext]
            
            let ringPoint1 = partsFactory.withdrawRingPoint()
            ringPoint1.x = originalRingPoint1.x
            ringPoint1.y = originalRingPoint1.y
            ringPoint1.triangleIndex = polyMesh.meshVertexIndex
            ringPoint1.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint2 = partsFactory.withdrawRingPoint()
            ringPoint2.x = originalRingPoint2.x
            ringPoint2.y = originalRingPoint2.y
            ringPoint2.triangleIndex = polyMesh.meshVertexIndex
            ringPoint2.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint3 = partsFactory.withdrawRingPoint()
            ringPoint3.x = originalRingPoint3.x
            ringPoint3.y = originalRingPoint3.y
            ringPoint3.triangleIndex = polyMesh.meshVertexIndex
            ringPoint3.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let ringPoint4 = partsFactory.withdrawRingPoint()
            ringPoint4.x = originalRingPoint4.x
            ringPoint4.y = originalRingPoint4.y
            ringPoint4.triangleIndex = polyMesh.meshVertexIndex
            ringPoint4.refreshMeshPoint()
            polyMesh.meshVertexIndex += 1
            
            let polyMeshTriangle1 = partsFactory.withdrawPolyMeshTriangle()
            polyMeshTriangle1.type = .test6
            polyMeshTriangle1.meshPoint1 = ringPoint1.meshPoint
            polyMeshTriangle1.meshPoint2 = ringPoint2.meshPoint
            polyMeshTriangle1.meshPoint3 = ringPointEar.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle1)
            
            let polyMeshTriangle2 = partsFactory.withdrawPolyMeshTriangle()
            polyMeshTriangle2.type = .test2
            polyMeshTriangle2.meshPoint1 = ringPoint2.meshPoint
            polyMeshTriangle2.meshPoint2 = ringPoint3.meshPoint
            polyMeshTriangle2.meshPoint3 = ringPointEar.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle2)
            
            let polyMeshTriangle3 = partsFactory.withdrawPolyMeshTriangle()
            polyMeshTriangle3.type = .test3
            polyMeshTriangle3.meshPoint1 = ringPoint3.meshPoint
            polyMeshTriangle3.meshPoint2 = ringPoint4.meshPoint
            polyMeshTriangle3.meshPoint3 = ringPointEar.meshPoint
            polyMesh.addPolyMeshTriangle(polyMeshTriangle3)
            
            polyMesh.addRingPoint(ringPoint1)
            polyMesh.addRingPoint(ringPoint2)
            polyMesh.addRingPoint(ringPoint3)
            polyMesh.addRingPoint(ringPoint4)
            polyMesh.addRingPoint(ringPointEar)
            
            return true
        }
    }
}
