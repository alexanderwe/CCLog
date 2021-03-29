//
//  Array.swift
//  
//
//  Created by Alexander Weiss on 29.03.21.
//

import Foundation

extension Array {
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }
}
