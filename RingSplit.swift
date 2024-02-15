//
//  RingSplit.swift
//  Jiggle3
//
//  Created by Nicky Taylor on 12/2/23.
//

import Foundation

class RingSplit: CustomStringConvertible {
    var index1 = 0
    var index2 = 0
    var splitQuality = RingSplitQuality()
    
    var description: String {
        "RS[\(index1), \(index2)] => \(splitQuality)"
    }
}
