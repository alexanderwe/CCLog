//
//  StencilContextConvertible.swift
//  
//
//  Created by Alexander Weiss on 14.03.21.
//

import Foundation


/// A protocol to confirm a type to be exposed to `Stencil` rendering
protocol StencilContextConvertible {
    func convertToStencilContext() -> [String: Any]
}
