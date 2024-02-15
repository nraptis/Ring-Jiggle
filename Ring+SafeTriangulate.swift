//
//  Ring+SafeTriangulate.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/3/23.
//

import Foundation

extension Ring {
    
    func meshifyWithSafeAlgorithm() {
        
        return
        
        let targetSweepLineCount = getTargetSweepLineCount()
            
        calculateHorizontalSweepLines(targetSweepLineCount)
        calculateHorizontalSweepPoints(targetSweepLineCount)
        
        sweepPointList.removeAll(keepingCapacity: true)
        var yIndex = 0
        while yIndex < sweepLines.count {
            
            let sweepLine = sweepLines[yIndex]
            
            for segmentIndex in sweepLine.segments.indices {
                let sweepSegment = sweepLine.segments[segmentIndex]
                
                for pointIndex in sweepSegment.points.indices {
                    let sweepPoint = sweepSegment.points[pointIndex]
                    
                    sweepPointList.append(sweepPoint)
                    
                    
                    //let normalizedX = (sweepPoint.x - minX) / rangeX
                    //let normalizedY = (sweepPoint.y - minY) / rangeY
                    
                    //var point = TriangulationPoint(x: sweepPoint.x,
                    //                               y: sweepPoint.y)
                    //point.x = sweepPoint.x
                    //point.y = sweepPoint.y
                    
                    //points.append(point)
                    //innerPoints.insert(point)
                    
                    
                }
            }
            yIndex += 1
        }
        
        let triangulator = DelauneyTriangulator.shared
        
        triangulator.triangulate(points: sweepPointList,
                                 hull: ringPoints)
        
        for triangle in triangulator.triangles {

            let ringPoint1 = partsFactory.withdrawRingPoint()
            ringPoint1.x = triangle.point1.x
            ringPoint1.y = triangle.point1.y
            ringPoint1.triangleIndex = polyMesh.meshVertexIndex
            polyMesh.meshVertexIndex += 1
            
            
            let ringPoint2 = partsFactory.withdrawRingPoint()
            ringPoint2.x = triangle.point2.x
            ringPoint2.y = triangle.point2.y
            ringPoint2.refreshMeshPoint()
            ringPoint2.triangleIndex = polyMesh.meshVertexIndex
            polyMesh.meshVertexIndex += 1
            
            let ringPoint3 = partsFactory.withdrawRingPoint()
            ringPoint3.x = triangle.point2.x
            ringPoint3.y = triangle.point2.y
            ringPoint3.refreshMeshPoint()
            ringPoint3.triangleIndex = polyMesh.meshVertexIndex
            polyMesh.meshVertexIndex += 1
            
            let polyMeshTriangle = partsFactory.withdrawPolyMeshTriangle()
            
            //mt.isFromSafeMethod = true
            polyMeshTriangle.type = .safe
            
            polyMeshTriangle.meshPoint1 = ringPoint1.meshPoint
            polyMeshTriangle.meshPoint2 = ringPoint2.meshPoint
            polyMeshTriangle.meshPoint3 = ringPoint3.meshPoint
            
            
            polyMesh.addRingPoint(ringPoint1)
            polyMesh.addRingPoint(ringPoint2)
            polyMesh.addRingPoint(ringPoint3)
            
            //addPolyMeshTriangle(polyMeshTriangle)
            polyMesh.addPolyMeshTriangle(polyMeshTriangle)
        }
        
        for ringPointIndex in 0..<ringPointCount {
            let ringPoint = ringPoints[ringPointIndex]
            polyMesh.addRingPoint(ringPoint)
        }
        
        ringPointCount = 0
    }
}
