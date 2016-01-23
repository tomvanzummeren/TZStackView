//
//  Array+Product.swift
//  TZStackView
//
//  Created by Pan Yusheng on 11/7/15.
//  Copyright © 2015 Tom van Zummeren. All rights reserved.
//

import Foundation

func * <E1, E2>(left: Array<E1>, right: Array<E2>) -> Array<(E1, E2)> {
    var result = [(E1, E2)]()
    
    for e1 in left {
        for e2 in right {
            result.append((e1, e2))
        }
    }
    
    return result
}

infix operator *+ {
    associativity left
    precedence 150
}

/// [[1], [2]] *+ [3, 4] = [[1, 3], [1, 4], [2, 3], [2, 4]]
/// Your can also write this as [[]] *+ [1, 2] *+ [3, 4]
func *+ <E>(left: [[E]], right: [E]) -> [[E]] {
    var result = [[E]]()
    
    for e1: [E] in left {
        for e2: E in right {
            result.append(e1 + [e2])
        }
    }
    
    return result
}