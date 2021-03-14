//
//  TagFilter.swift
//  
//
//  Created by Alexander Weiss on 12.12.20.
//

import Foundation

struct TagFilter {
    
    let regex: NSRegularExpression
    private let filterString: String
    
    public init?(string: String) {
        filterString = string
        
        guard let reg = try? NSRegularExpression(pattern: string) else {
            return nil
        }
        regex = reg
    }
}
