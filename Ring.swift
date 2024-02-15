//
//  Ring.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 1/6/24.
//

import Foundation

let DEBUG_RING = false
let DEBUG_SUBRING = true

class Ring {
    
    static let maxPointCount = 256
    
    typealias Point = Math.Point
    typealias Vector = Math.Vector
    
    var ringPoints = [RingPoint]()
    var ringPointCount = 0
    func addRingPoint(_ ringPoint: RingPoint) {
        while ringPoints.count <= ringPointCount {
            ringPoints.append(ringPoint)
        }
        ringPoints[ringPointCount] = ringPoint
        ringPointCount += 1
    }
    
    func removeRingPoint(_ index: Int) {
        if index >= 0 && index < ringPointCount {
            partsFactory.depositRingPoint(ringPoints[index])
            let ringPointCount1 = ringPointCount - 1
            var ringPointIndex = index
            while ringPointIndex < ringPointCount1 {
                ringPoints[ringPointIndex] = ringPoints[ringPointIndex + 1]
                ringPointIndex += 1
            }
            ringPointCount -= 1
        }
    }
    
    var ringLineSegments = [RingLineSegment]()
    var ringLineSegmentCount = 0
    func addRingLineSegment() {
        let ringLineSegment = partsFactory.withdrawRingLineSegment()
        while ringLineSegments.count <= ringLineSegmentCount {
            ringLineSegments.append(ringLineSegment)
        }
        ringLineSegments[ringLineSegmentCount] = ringLineSegment
        ringLineSegmentCount += 1
    }
    
    func addRingLineSegmentFastSplit(_ ringLineSegment: RingLineSegment) {
        let newRingLineSegment = partsFactory.withdrawRingLineSegment()
        ringLineSegment.writeToFastSplit(newRingLineSegment)
        newRingLineSegment.ringIndex = ringPointCount
        addRingLineSegment(newRingLineSegment)
    }
    
    func addRingLineSegment(_ ringLineSegment: RingLineSegment) {
        while ringLineSegments.count <= ringLineSegmentCount {
            ringLineSegments.append(ringLineSegment)
        }
        ringLineSegments[ringLineSegmentCount] = ringLineSegment
        ringLineSegmentCount += 1
    }
    
    var ringProbePoints = [RingProbePoint]()
    var ringProbePointCount = 0
    func addRingProbePoint(_ ringProbePoint: RingProbePoint) {
        while ringProbePoints.count <= ringProbePointCount {
            ringProbePoints.append(ringProbePoint)
        }
        ringProbePoints[ringProbePointCount] = ringProbePoint
        ringProbePointCount += 1
    }
    
    var ringProbeSegments = [RingProbeSegment]()
    var ringProbeSegmentCount = 0
    func addRingProbeSegment(_ ringProbeSegment: RingProbeSegment) {
        while ringProbeSegments.count <= ringProbeSegmentCount {
            ringProbeSegments.append(ringProbeSegment)
        }
        ringProbeSegments[ringProbeSegmentCount] = ringProbeSegment
        ringProbeSegmentCount += 1
    }
    
    let ringPointInsidePolygonBucket = RingPointInsidePolygonBucket()
    //let probePointInsidePolygonBucket = ProbePointInsidePolygonBucket()
    
    
    let ringLineSegmentBucket = RingLineSegmentBucket()
    let ringProbeSegmentBucket = RingProbeSegmentBucket()
    
    unowned var partsFactory: PolyMeshPartsFactory!
    unowned var polyMesh: PolyMesh!
    
    
    
    init(partsFactory: PolyMeshPartsFactory, polyMesh: PolyMesh) {
        self.partsFactory = partsFactory
        self.polyMesh = polyMesh
    }
    
    func buildRingPointInsidePolygonBucket() {
        ringPointInsidePolygonBucket.build(ringLineSegments: ringLineSegments, ringLineSegmentCount: ringLineSegmentCount)
    }
    
    
    //func buildProbePointInsidePolygonBucket() {
    //    probePointInsidePolygonBucket.build(probeSegments: ringProbeSegments)
    //}
    
    //@Precondition: calculateLineSegments
    func buildLineSegmentBucket() {
        ringLineSegmentBucket.build(ringLineSegments: ringLineSegments, ringLineSegmentCount: ringLineSegmentCount)
    }
    
    //@Precondition: calculateProbeSegmentsUsingProbePoints
    func buildRingProbeSegmentBucket() {
        ringProbeSegmentBucket.build(ringProbeSegments: ringProbeSegments, ringProbeSegmentCount: ringProbeSegmentCount)
    }
    
    func setAllProbePointsIllegalToFalse() {
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            ringProbePoint.isIllegal = false
        }
    }
    
    func setAllProbePointsMeldedToFalse() {
        for ringProbePointIndex in 0..<ringProbePointCount {
            let ringProbePoint = ringProbePoints[ringProbePointIndex]
            ringProbePoint.isMelded = false
        }
    }
    
    var isBroken = false
    
    let preComputedLineSegment1 = AnyPrecomputedLineSegment()
    let preComputedLineSegment2 = AnyPrecomputedLineSegment()
    let preComputedLineSegment3 = AnyPrecomputedLineSegment()
    let preComputedLineSegment4 = AnyPrecomputedLineSegment()
    
    var subrings = [Ring]()
    var subringCount = 0
    func addSubring(_ subring: Ring) {
        while subrings.count <= subringCount {
            subrings.append(subring)
        }
        subrings[subringCount] = subring
        subringCount += 1
        
        subring.parent = self
        
        /*
        for polyMeshTriangleIndex in 0..<subring.polyMeshTriangleCount {
            let polyMeshTriangle = subring.polyMeshTriangles[polyMeshTriangleIndex]
            polyMesh.addPolyMeshTriangle(polyMeshTriangle)
        }
        subring.polyMeshTriangleCount = 0
        
        for polyMeshRingPointIndex in 0..<subring.polyMeshRingPointCount {
            let polyMeshRingPoint = subring.polyMeshRingPoints[polyMeshRingPointIndex]
            polyMesh.addRingPoint(polyMeshRingPoint)
        }
        subring.polyMeshRingPointCount = 0
        */
    }
    func purgeSubrings() {
        for subringIndex in 0..<subringCount {
            let subring = subrings[subringIndex]
            partsFactory.depositRing(subring)
        }
        subringCount = 0
    }
    
    weak var parent: Ring?
    
    /*
    var savedRingProbePoints = [RingProbePoint]()
    var savedRingProbePointCount = 0
    func addSavedRingProbePoint(_ ringProbePoint: RingProbePoint) {
        while savedRingProbePoints.count <= savedRingProbePointCount {
            savedRingProbePoints.append(ringProbePoint)
        }
        savedRingProbePoints[savedRingProbePointCount] = ringProbePoint
        savedRingProbePointCount += 1
    }
    */
    
    var temp_1_ringPoints = [RingPoint]()
    var temp_1_ringPointCount = 0
    func addTemp_1_RingPoint(_ ringPoint: RingPoint) {
        while temp_1_ringPoints.count <= temp_1_ringPointCount {
            temp_1_ringPoints.append(ringPoint)
        }
        temp_1_ringPoints[temp_1_ringPointCount] = ringPoint
        temp_1_ringPointCount += 1
    }
    
    var temp_1_ringLineSegments = [RingLineSegment]()
    var temp_1_ringLineSegmentCount = 0
    func addTemp_1_RingLineSegment(_ ringLineSegment: RingLineSegment) {
        while temp_1_ringLineSegments.count <= temp_1_ringLineSegmentCount {
            temp_1_ringLineSegments.append(ringLineSegment)
        }
        temp_1_ringLineSegments[temp_1_ringLineSegmentCount] = ringLineSegment
        temp_1_ringLineSegmentCount += 1
    }
    
    var temp_1_ringProbePoints = [RingProbePoint]()
    var temp_1_ringProbePointCount = 0
    func addTemp_1_RingProbePoint(_ ringProbePoint: RingProbePoint) {
        while temp_1_ringProbePoints.count <= temp_1_ringProbePointCount {
            temp_1_ringProbePoints.append(ringProbePoint)
        }
        temp_1_ringProbePoints[temp_1_ringProbePointCount] = ringProbePoint
        temp_1_ringProbePointCount += 1
    }
    
    var temp_2_ringProbePoints = [RingProbePoint]()
    var temp_2_ringProbePointCount = 0
    func addTemp_2_RingProbePoint(_ ringProbePoint: RingProbePoint) {
        while temp_2_ringProbePoints.count <= temp_2_ringProbePointCount {
            temp_2_ringProbePoints.append(ringProbePoint)
        }
        temp_2_ringProbePoints[temp_2_ringProbePointCount] = ringProbePoint
        temp_2_ringProbePointCount += 1
    }
    
    var temp_1_ringProbeSegments = [RingProbeSegment]()
    var temp_1_ringProbeSegmentCount = 0
    func addTemp_1_RingProbeSegment(_ ringProbeSegment: RingProbeSegment) {
        while temp_1_ringProbeSegments.count <= temp_1_ringProbeSegmentCount {
            temp_1_ringProbeSegments.append(ringProbeSegment)
        }
        temp_1_ringProbeSegments[temp_1_ringProbeSegmentCount] = ringProbeSegment
        temp_1_ringProbeSegmentCount += 1
    }
    
    var tempRingSplitQuality = RingSplitQuality()
    
    //var ringProbePointsTemp = [RingProbePoint]()
    
    //var buttressGroup = [RingProbePoint]()
    
    //var possibleSplitPairsStrong = [RingPinch]()
    //var possibleSplitPairsWeak = [RingPinch]()
    //var possibleSplitPairsTemp = [RingPinch]()
    
    
    //struct _PossibleSplitPair: Hashable {
    //    let index1: Int
    //    let index2: Int
    //}
    
    var possibleSplitPairs = [PossibleSplitPair]()
    var possibleSplitPairCount = 0
    
    func addPossibleSplitPair(_ possibleSplitPair: PossibleSplitPair) {
        while possibleSplitPairs.count <= possibleSplitPairCount {
            possibleSplitPairs.append(possibleSplitPair)
        }
        possibleSplitPairs[possibleSplitPairCount] = possibleSplitPair
        possibleSplitPairCount += 1
    }
    
    func possibleSplitPairsContains(ringPoint1: RingPoint,
                                    ringPoint2: RingPoint) -> Bool {
        for possibleSplitPairIndex in 0..<possibleSplitPairCount {
            let possibleSplitPair = possibleSplitPairs[possibleSplitPairIndex]
            if possibleSplitPair.ringPoint1 === ringPoint1 && possibleSplitPair.ringPoint2 === ringPoint2 {
                //print("PSP contained...")
                return true
            }
        }
        return false
    }
    
    //var possibleSplitPairsMap = Set<_PossibleSplitPair>()
    
    //var tempProbePoints = [RingProbePoint]()
    //var tempProbePointGroups = [RingProbePointGroup]()
    
    
    //var storedProbePoints = [RingProbePoint]()
    
    //var isSplit = false
    
    var ringSplits = [RingSplit]()
    var ringSplitCount = 0
    func addRingSplit(_ ringSplit: RingSplit) {
        while ringSplits.count <= ringSplitCount {
            ringSplits.append(ringSplit)
        }
        ringSplits[ringSplitCount] = ringSplit
        ringSplitCount += 1
    }
    func removeRingSplit(_ ringSplit: RingSplit) {
        for checkIndex in 0..<ringSplitCount {
            if ringSplits[checkIndex] === ringSplit {
                removeRingSplit(checkIndex)
                return
            }
        }
    }
    func removeRingSplit(_ index: Int) {
        if index >= 0 && index < ringSplitCount {
            let ringSplitCount1 = ringSplitCount - 1
            var ringSplitIndex = index
            while ringSplitIndex < ringSplitCount1 {
                ringSplits[ringSplitIndex] = ringSplits[ringSplitIndex + 1]
                ringSplitIndex += 1
            }
            ringSplitCount -= 1
        }
    }
    
    var meldProbePoints = [RingProbePoint]()
    var meldProbePointCount = 0
    func addMeldProbePoint(_ ringProbePoint: RingProbePoint) {
        while meldProbePoints.count <= meldProbePointCount {
            meldProbePoints.append(ringProbePoint)
        }
        meldProbePoints[meldProbePointCount] = ringProbePoint
        meldProbePointCount += 1
    }
    
    var meldLocalLineSegments = [RingLineSegment]()
    var meldLocalLineSegmentCount = 0
    func addMeldLocalLineSegment(_ ringLineSegment: RingLineSegment) {
        while meldLocalLineSegments.count <= meldLocalLineSegmentCount {
            meldLocalLineSegments.append(ringLineSegment)
        }
        meldLocalLineSegments[meldLocalLineSegmentCount] = ringLineSegment
        meldLocalLineSegmentCount += 1
    }
    
    var meldLocalDisjointProbeSegments = [RingProbeSegment]()
    var meldLocalDisjointProbeSegmentCount = 0
    func addMeldLocalDisjointProbeSegment(_ ringProbeSegment: RingProbeSegment) {
        while meldLocalDisjointProbeSegments.count <= meldLocalDisjointProbeSegmentCount {
            meldLocalDisjointProbeSegments.append(ringProbeSegment)
        }
        meldLocalDisjointProbeSegments[meldLocalDisjointProbeSegmentCount] = ringProbeSegment
        meldLocalDisjointProbeSegmentCount += 1
    }
    
    var meldProbeSpokes = [RingProbeSpoke]()
    var meldProbeSpokeCount = 0
    func addMeldProbeSpoke(_ ringProbeSpoke: RingProbeSpoke) {
        while meldProbeSpokes.count <= meldProbeSpokeCount {
            meldProbeSpokes.append(ringProbeSpoke)
        }
        meldProbeSpokes[meldProbeSpokeCount] = ringProbeSpoke
        meldProbeSpokeCount += 1
    }
    
    var possibleMelds = [PossibleMeld]()
    var possibleMeldCount = 0
    func addPossibleMeld(_ possibleMeld: PossibleMeld) {
        while possibleMelds.count <= possibleMeldCount {
            possibleMelds.append(possibleMeld)
        }
        possibleMelds[possibleMeldCount] = possibleMeld
        possibleMeldCount += 1
    }
    
    var ringMelds = [RingMeld]()
    var ringMeldCount = 0
    func addRingMeld(_ ringMeld: RingMeld) {
        while ringMelds.count <= ringMeldCount {
            ringMelds.append(ringMeld)
        }
        ringMelds[ringMeldCount] = ringMeld
        ringMeldCount += 1
    }
    
    func meldProbePointsContains(ringProbePoint: RingProbePoint) -> Bool {
        var meldProbePointIndex = 0
        while meldProbePointIndex < meldProbePointCount {
            if meldProbePoints[meldProbePointIndex] === ringProbePoint {
                return true
            }
            meldProbePointIndex += 1
        }
        return false
    }
    
    func meldProbeSpokesContainsConnection(_ connection: RingPoint) -> Bool {
        var meldProbeSpokeIndex = 0
        while meldProbeSpokeIndex < meldProbeSpokeCount {
            if meldProbeSpokes[meldProbeSpokeIndex].connection === connection {
                return true
            }
            meldProbeSpokeIndex += 1
        }
        return false
    }

    
    
    var possibleCapOffs = [PossibleCapOff]()
    var possibleCapOffCount = 0
    func addPossibleCapOff(_ possibleCapOff: PossibleCapOff) {
        while possibleCapOffs.count <= possibleCapOffCount {
            possibleCapOffs.append(possibleCapOff)
        }
        possibleCapOffs[possibleCapOffCount] = possibleCapOff
        possibleCapOffCount += 1
    }
    
    var sweepLines = [RingSweepLine]()
    var sweepSegmentBucket = [[RingLineSegment]]()
    var sweepCollisionBucket = [[RingSweepCollision]]()
    var sweepPointList = [RingSweepPoint]()
    var splitQuality = RingSplitQuality()
    
    
    //unowned var partsFactory: PolyMeshPartsFactory!
    //unowned var polyMesh: PolyMesh!
    var depth: UInt32 = 0
    
    //let delaunaySentinalPoint0 = RingMeshPoint()
    //let delaunaySentinalPoint1 = RingMeshPoint()
    //let delaunaySentinalPoint2 = RingMeshPoint()
    
    //var clipEarNewPointsTemp = [RingPoint]()
    
    //var smartReplaceNewPointsTemp = [RingPoint]()
    //var smartReplaceNewLineSegmentsTemp = [RingLineSegment]()
    
    //var supercollidersLeft = [Bool](repeating: false, count: 4)
    //var supercollidersRight = [Bool](repeating: false, count: 4)
    
    func addPointsBegin(depth: UInt32) {
        self.depth = depth
        purgeRingPoints()
    }
    
    func addPoint(_ x: Float, _ y: Float) {
        let newRingPoint = partsFactory.withdrawRingPoint()
        newRingPoint.x = x
        newRingPoint.y = y
        newRingPoint.ringIndex = ringPointCount
        addRingPoint(newRingPoint)
    }
    
    func addPointFastSplit(_ ringPoint: RingPoint) {
        let newRingPoint = partsFactory.withdrawRingPoint()
        ringPoint.writeToFastSplit(newRingPoint)
        newRingPoint.ringIndex = ringPointCount
        addRingPoint(newRingPoint)
    }
    
    static func debugRing(_ ring: Ring) {
        
        print("ring depth: \(ring.depth)")
        print("jiggle.polyMesh.addPointsBegin()")
        
        for ringPointIndex in 0..<ring.ringPointCount {
            let ringPoint = ring.ringPoints[ringPointIndex]
            print("jiggle.addControlPoint(\(ringPoint.x), \(ringPoint.y))")
        }
        print("jiggle.isForceJumpMode = true")
    }
    
    func meshifyRecursively(needsSafetyCheckA: Bool, needsSafetyCheckB: Bool) {
        
        //TODO: It could be, we are already SPLIT...
        
        if ringPointCount <= 0 && subringCount > 0 {
            /*
            for subringIndex in 0..<subringCount {
                let subring = subrings[subringIndex]
                if subring.attemptToBeginBuildAndCheckIfBroken(needsPointInsidePolygonBucket: true,
                                                               needsLineSegmentBucket: true) {
                    subring.meshifyRecursively(needsSafetyCheckA: true, needsSafetyCheckB: true)
                } else {
                    
                }
            }
            */
            fatalError("why?")
            return
        }
        
        for ringPointIndex in 0..<ringPointCount {
            ringPoints[ringPointIndex].triangleIndex = polyMesh.meshVertexIndex
            polyMesh.meshVertexIndex += 1
            ringPoints[ringPointIndex].refreshMeshPoint()
        }
        
        if needsSafetyCheckA {
            if !attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
                meshifyWithSafeAlgorithm()
                return
            }
        }
        
        var continueToClipEars = true
        var didClipEar = false
        
        var earClipCount = 0
        while continueToClipEars == true && ringPointCount >= 3 {
            earClipCount += 1
            continueToClipEars = attemptToClipEar()
            if continueToClipEars {
                didClipEar = true
                
                if earClipCount == TOOL_LINE_SEGMENT_NORMALS_LEVEL { break }
            }
        }
        
        //Self.debugRing(self)
        
        
        //TODO: This should be the only time we do attemptCalculateBasicsAndDetermineSafetyPartA
        
        if didClipEar {
            if !attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
                meshifyWithSafeAlgorithm()
                return
            }
        }
        
        if didClipEar || needsSafetyCheckB {
            
            //fixRingPointAndLineSegmentAdjacency()
            
            if !attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: true,
                                                       needsLineSegmentBucket: true,
                                                       test: false) {
                meshifyWithSafeAlgorithm()
                return
            }
        }
        
        if ringPointCount < 3 {
            print("Why is ringPointCount \(ringPointCount) < 3? Should have missed on SAFETY CHECK!!!")
        }
        
        calculateRingPointPinchGates()
        buildRingPointInsidePolygonBucket()
        buildLineSegmentBucket()
        
        /*
        if shouldCapOff() {
            if attemptCapOff() {
                return
            }
        }
        */
        
        calculateLineSegmentContentions()
        
        calculatePossibleSplits()
        
        if calculateRingSplitsAndExecuteInstantSplitIfExists() {
            for subringIndex in 0..<subringCount {
                let subring = subrings[subringIndex]
                subring.meshifyRecursively(needsSafetyCheckA: false,
                                           needsSafetyCheckB: false)
            }
            return
        }
        
        if attemptInset(needsContentions: false) {
            for subringIndex in 0..<subringCount {
                let subring = subrings[subringIndex]
                subring.meshifyRecursively(needsSafetyCheckA: false,
                                           needsSafetyCheckB: false)
            }
            return
        } else {
            
            if subringCount > 0 {
                print("how?")
            }
            
            // We can try one of the remaining splits...
            
            if executeBestSplitPossible() {
                for subringIndex in 0..<subringCount {
                    let subring = subrings[subringIndex]
                    subring.meshifyRecursively(needsSafetyCheckA: false,
                                               needsSafetyCheckB: false)
                }
                return
            } else {
                
                // We can try to cap off...?
                
                meshifyWithSafeAlgorithm()
                
            }
            
            
        }
        
        
        /*
        if !attemptBuildSubrings() {
            
        }
        */
        
    }
    
    func attemptToBeginBuildAndCheckIfBroken(needsPointInsidePolygonBucket: Bool, needsLineSegmentBucket: Bool) -> Bool {
        if ringPointCount < 3 {
            isBroken = true
            return false
        }
        
        if containsDuplicatePointsOuter() {
            isBroken = true
            return false
        }
        
        if containsTooFewPoints() {
            isBroken = true
            return false
        }
        
        if isCounterClockwiseRingPoints() {
            isBroken = true
            return false
        }
        
        if !attemptCalculateBasicsAndDetermineSafetyPartA(test: false) {
            return false
        }
        
        if !attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: needsPointInsidePolygonBucket,
                                                   needsLineSegmentBucket: needsLineSegmentBucket,
                                                   test: false) {
            return false
        }
        
        
        return true
    }
    
    /*
    func attemptCalculateBasicsAndDetermineSafety() -> Bool {
        if !attemptCalculateBasicsAndDetermineSafetyPartA() {
            return false
        }
        if !attemptCalculateBasicsAndDetermineSafetyPartB() {
            return false
        }
        return true
    }
    */
    
    func attemptCalculateBasicsAndDetermineSafetyPartA(test: Bool) -> Bool {
    
        if ringPointCount < 3 {
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} ringPointCount \(ringPointCount) < 3")
                }
            }
            
            return false
        }
        
        calculateRingPointNeighborsAndIndices()
        
        if !attemptCalculateLineSegments() {
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} containsIllegalLineSegments()")
                }
            }
            
            return false
        }
        
        if !attemptCalculateRingPointNormals() {
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} containsIllegalPoint()")
                }
            }
            
            return false
        }
        
        if !attemptCalculateRingPointAngularSpans() {
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} containsIllegalPoint()")
                }
            }
            return false
        }
        
        return true
    }
    
    func attemptCalculateBasicsAndDetermineSafetyPartB(needsPointInsidePolygonBucket: Bool, needsLineSegmentBucket: Bool, test: Bool) -> Bool {
        
        if needsPointInsidePolygonBucket {
            buildRingPointInsidePolygonBucket()
        }
        
        if needsLineSegmentBucket {
            buildLineSegmentBucket()
        }
        
        if containsPointsThatAreTooCloseToLineSegmentsInnerRing() {
            //print("BASIC SAFETY VIOLATION B-1 Point-Too-Close")
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} containsPointsThatAreTooCloseToLineSegmentsInnerRing()")
                }
            }
            
            return false
        }
        
        if isComplexLineSegments() {
            //print("BASIC SAFETY VIOLATION B-2 Self-Intersect (Complex)")
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} isComplexLineSegments()")
                }
            }
            
            return false
        }
        
        if isCounterClockwiseRingPoints() {
            //print("BASIC SAFETY VIOLATION B-3 Counter-Clockwise")
            isBroken = true
            
            if DEBUG_RING {
                if !test {
                    print("[Ring] [X28] @ \(depth) with \(ringPoints.count) points {Broken} isCounterClockwiseRingPoints()")
                }
            }
            
            return false
        }
        
        return true
    }
    
    func calculatePointCornerOutliers() {
        
        
        let outlierDistanceThreshold = (PolyMeshConstants.ringInsetAmountThreatNone * 1.25)
        let outlierDistanceThresholdSquared = outlierDistanceThreshold * outlierDistanceThreshold
        
        for ringPointIndex in 0..<ringPointCount {
            let ringPoint = ringPoints[ringPointIndex]
            
            if ringPoint.angularSpan > Math.pi4_3 {
                ringPoint.isCornerOutlier = true
            } else {
                
                let cornerPointX = ringPoint.probeSegmentForCollider.colliderPointX
                let cornerPointY = ringPoint.probeSegmentForCollider.colliderPointY
                
                let distanceSquared = ringPoint.distanceSquared(x: cornerPointX, y: cornerPointY)
                
                if ringPoint.angularSpan > Math.pi {
                    if distanceSquared > outlierDistanceThresholdSquared {
                        ringPoint.isCornerOutlier = true
                    } else {
                        ringPoint.isCornerOutlier = false
                    }
                } else {
                    ringPoint.isCornerOutlier = false
                }
            }
        }
    }
    
    func indexOfProbePoint(_ ringProbePoint: RingProbePoint) -> Int? {
        for ringProbePointIndex in 0..<ringProbePointCount {
            if ringProbePoints[ringProbePointIndex] === ringProbePoint {
                return ringProbePointIndex
            }
        }
        return nil
    }
    
    func indexOfRingPoint(_ ringPoint: RingPoint) -> Int? {
        for ringPointIndex in 0..<ringPointCount {
            if ringPoints[ringPointIndex] === ringPoint {
                return ringPointIndex
            }
        }
        return nil
    }
    
    func getRingPoint(at index: UInt16) -> RingPoint? {
        if index >= 0 && index < ringPointCount {
            return ringPoints[Int(index)]
        }
        return nil
    }
    
    func getRingPoint(at index: Int) -> RingPoint? {
        if index >= 0 && index < ringPointCount {
            return ringPoints[index]
        }
        return nil
    }
    
    func getRingLineSegment(at index: UInt16) -> RingLineSegment? {
        if index >= 0 && index < ringLineSegmentCount {
            return ringLineSegments[Int(index)]
        }
        return nil
    }
    
    func getRingLineSegment(at index: Int) -> RingLineSegment? {
        if index >= 0 && index < ringLineSegmentCount {
            return ringLineSegments[index]
        }
        return nil
    }
    
}

