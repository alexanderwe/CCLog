//
//  Substring.swift
//  
//
//  Created by Alexander Weiß on 10.11.20.
//

import Foundation

// MARK: - Type extensions

//MARK: Int
// Parser<Int>.int
// .int
extension Parser where Input == Substring, Output == Int {
    public static let int = Self { input in
        let original = input
        
        var isFirstCharacter = true
        let intPrefix = input.prefix { character in
            defer { isFirstCharacter = false }
            return (character == "-" || character == "+") && isFirstCharacter
                || character.isNumber
        }
        
        guard let match = Int(intPrefix)
        else {
            input = original
            return nil
        }
        input.removeFirst(intPrefix.count)
        return match
    }
}

//MARK: Double
extension Parser where Input == Substring, Output == Double {
    public  static let double = Self { input in
        let original = input
        let sign: Double
        if input.first == "-" {
            sign = -1
            input.removeFirst()
        } else if input.first == "+" {
            sign = 1
            input.removeFirst()
        } else {
            sign = 1
        }
        
        var decimalCount = 0
        let prefix = input.prefix { char in
            if char == "." { decimalCount += 1 }
            return char.isNumber || (char == "." && decimalCount <= 1)
        }
        
        guard let match = Double(prefix)
        else {
            input = original
            return nil
        }
        
        input.removeFirst(prefix.count)
        
        return match * sign
    }
}

// MARK: Character
extension Parser where Input == Substring, Output == Character {
    public static let char = Self { input in
        guard !input.isEmpty else { return nil }
        return input.removeFirst()
    }
}

// MARK: - ExpressibleBy*
extension Parser: ExpressibleByUnicodeScalarLiteral where Input == Substring, Output == Void {
    public typealias UnicodeScalarLiteralType = StringLiteralType
}

extension Parser: ExpressibleByExtendedGraphemeClusterLiteral where Input == Substring, Output == Void {
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
}

extension Parser: ExpressibleByStringLiteral where Input == Substring, Output == Void {
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
        self = .prefix(value[...])
    }
}


// MARK: - Convenience
extension Parser where Input == Substring, Output == Substring {
  public static var rest: Self {
    Self { input in
      let rest = input
      input = ""
      return rest
    }
  }
}


extension Parser where Input == Substring, Output == Substring {
    public static func prefix(upToRegex regex: String) -> Self {
        Self { input in
            
            let strInput = String(input)
            let regex = try! NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
            let regexMatches = regex.matches(in: strInput, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            guard let regexMatch = regexMatches.first,
                  let range = Range(regexMatch.range(at: 1), in: input)
            else {
                return nil
            }
            
            
            let endIndex = range.lowerBound
            
            let match = input[..<endIndex]
            
            input = input[endIndex...]
            
            return match
        }
    }
}
