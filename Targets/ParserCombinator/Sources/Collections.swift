//
//  File.swift
//  
//
//  Created by Alexander Weiß on 10.11.20.
//

import Foundation


// MARK: - Prefix
extension Parser
where Input: Collection,
      Input.SubSequence == Input,
      Output == Void,
      Input.Element: Equatable {
    
      public static func prefix(_ p: Input.SubSequence) -> Self {
          Self { input in
              guard input.starts(with: p) else { return nil }
              input.removeFirst(p.count)
              return ()
          }
      }
}

extension Parser
where
    Input: Collection,
    Input.SubSequence == Input,
    Output == Input {
    
    public static func prefix(while p: @escaping (Input.Element) -> Bool) -> Self {
        Self { input in
            let output = input.prefix(while: p)
            input.removeFirst(output.count)
            return output
        }
    }
}

extension Parser
where
    Input: Collection,
    Input.SubSequence == Input,
    Input.Element: Equatable,
    Output == Input {
    
    public static func prefix(upTo subsequence: Input) -> Self {
        Self { input in
            guard !subsequence.isEmpty else { return subsequence }
            let original = input
            while !input.isEmpty {
                if input.starts(with: subsequence) {
                    return original[..<input.startIndex]
                } else {
                    input.removeFirst()
                }
            }
            input = original
            return nil
        }
    }
}

extension Parser
where
    Input: Collection,
    Input.SubSequence == Input,
    Input.Element: Equatable,
    Output == Input {
    public static func prefix(through subsequence: Input) -> Self {
        Self { input in
            guard !subsequence.isEmpty else { return subsequence }
            let original = input
            while !input.isEmpty {
                if input.starts(with: subsequence) {
                    return original[..<input.startIndex]
                } else {
                    let index = input.index(input.startIndex, offsetBy: subsequence.count)
                    input = input[index...]
                    return original[..<index]
                }
            }
            input = original
            return nil
        }
    }
}
