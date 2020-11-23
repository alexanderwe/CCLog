//
//  File.swift
//  
//
//  Created by Alexander Weiß on 23.11.20.
//

import Foundation

extension Parser where Input: RangeReplaceableCollection {
    
    var stream: Parser<AnyIterator<Input>, [Output]> {
        .init { stream in
            var buffer = Input()
            var outputs: [Output] = []
            
            while let chunk = stream.next() {
                buffer.append(contentsOf: chunk)
                while let output = self.run(&buffer) {
                    outputs.append(output)
                }
            }
            return outputs
        }
    }
}


extension Parser where Input: RangeReplaceableCollection {
    
    func run(
        input: inout AnyIterator<Input>,
        output streamOut: (Output) -> Void
    ) {
        var buffer = Input()
        while let chunk = input.next() {
            buffer.append(contentsOf: chunk)
            while let output = self.run(&buffer) {
                streamOut(output)
            }
        }
    }
    
}
