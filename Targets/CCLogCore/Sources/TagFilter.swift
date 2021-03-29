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
        filterString = string.replacingOccurrences(of: "\\", with: "\\\\")
        guard let reg = try? NSRegularExpression(pattern: filterString) else {
            return nil
        }
        regex = reg
    }
}
