//
//  Array+Group.swift
//  TZStackView
//
//  Created by CosynPa on 1/24/16.
//  Copyright © 2016 Tom van Zummeren. All rights reserved.
//

import Foundation

extension Array {
    func groupBy<Key: Hashable>(keyFunc: Element -> Key) -> [Key: [Element]] {
        var result = [Key: [Element]]()
        for element in self {
            let key = keyFunc(element)
            
            var aGroup = result[key] ?? []
            aGroup.append(element)
            
            result[key] = aGroup
        }
        return result
    }
}
