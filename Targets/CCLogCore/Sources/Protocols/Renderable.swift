//
//  Renderable.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation

protocol Renderable {
    func render() -> Result<String, NSError>
}
