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
