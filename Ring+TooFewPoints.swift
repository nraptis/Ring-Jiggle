//
//  Ring+TooFewPoints.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 11/22/23.
//

import Foundation

extension Ring {
    func containsTooFewPoints() -> Bool {
        return ringPointCount < 3
    }
}
