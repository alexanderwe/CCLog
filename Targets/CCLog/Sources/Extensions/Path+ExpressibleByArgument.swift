//
//  File.swift
//  
//
//  Created by Alexander Weiß on 28.10.20.
//

import Foundation
import ArgumentParser

struct Path: ExpressibleByArgument {
    var pathString: String

    init?(argument: String) {
        self.pathString = argument
    }
    
    var url: URL? {
        return URL(string: self.pathString)
    }
}
