//
//  SemanticVersion.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import ParserCombinator

// MARK: - SemanticVersion
public struct SemanticVersion {

    let core: Core
    public let preReleaseIdentifiers: [String]
    public let buildIdentifiers: [String]
    
    public var major: Int {
        return core.major
    }
    
    public var minor: Int {
        core.minor
    }
    
    public var patch: Int {
        core.patch
    }
}

// MARK: - Parser
extension SemanticVersion {
    
    private static let parser: Parser<Substring, SemanticVersion> = {
        
        let alphaNumericAndHypen = Parser<Substring, Substring>
            .prefix(while: { $0.isLetter || $0.isNumber || $0 == "-" })
        
        // Pre-Release identifiers
        let preReleaseIdentifier = alphaNumericAndHypen
            .map(String.init)
        
        let preReleaseIdentifiersParser = Parser<Substring, Void>.skip("-")
            .take(preReleaseIdentifier.zeroOrMore(separatedBy: "."))
        
        // Build identifiers
        let buildIdentifier = alphaNumericAndHypen
            .map(String.init)
        
        let buildIdentifierParser = Parser<Substring, Void>.skip("+")
            .take(buildIdentifier.zeroOrMore(separatedBy: "."))
        
        return Core.parser
            .take(.optional(preReleaseIdentifiersParser))
            .take(.optional(buildIdentifierParser))
            .map { core, preReleaseIdentifiers, buildIdentifierParser  in
                return SemanticVersion(core: core,
                                       preReleaseIdentifiers: preReleaseIdentifiers != nil ? preReleaseIdentifiers! : [],
                                       buildIdentifiers:  buildIdentifierParser != nil ? buildIdentifierParser! : []
                )
            }
    }()
    
    public init?(data: String) {
        guard let match = SemanticVersion.parser.run(data[...]).match else {
            return nil
        }
        
        self = match
    }
    
    internal init(major: Int, minor: Int, patch: Int, preReleaseIdentifiers: [String] = [], buildIdentifiers: [String] = []) {
        self.core = Core(major: major, minor: minor, patch: patch)
        self.preReleaseIdentifiers = preReleaseIdentifiers
        self.buildIdentifiers = buildIdentifiers
    }
}

//MARK: - Comparable
extension SemanticVersion: Comparable {
    public static func == (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        return !(lhs < rhs) && !(lhs > rhs)
    }
    
    //Credit: https://github.com/glwithu06/Semver.swift/blob/master/Sources/Semver.swift
    public static func <(lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        
        for (left, right) in zip([lhs.major, lhs.minor, lhs.patch],  [rhs.major, rhs.minor, rhs.patch]) where left != right {
            return left < right
        }
        
        // If both vesions are equal, preReleaseIdentifiers are needed to be checked
        if lhs.preReleaseIdentifiers.count == 0 { return false }
        if rhs.preReleaseIdentifiers.count == 0 { return true }
        
        for (l, r) in zip(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers) {
               switch (l.isNumber, r.isNumber) {
               case (true, true):
                   let result = l.compare(r, options: .numeric)
                   if result == .orderedSame {
                       continue
                   }
                   return result == .orderedAscending
               case (true, false): return true
               case (false, true): return false
               default:
                   if l == r {
                       continue
                   }
                   return l < r
               }
           }

        return lhs.preReleaseIdentifiers.count < rhs.preReleaseIdentifiers.count
    }
}


// MARK: - Core
extension SemanticVersion {
    struct Core {
        public let major: Int
        public let minor: Int
        public let patch: Int
        
        internal static let parser: Parser<Substring, Core> = {
            return Parser<Substring, Int>.int
                .skip(".")
                .take(.int)
                .skip(".")
                .take(.int)
                .map { major, minor, patch in
                    return Core(major:major, minor: minor, patch: patch)
                }
        }()
    }
}

// MARK: - Helpers
extension String {
    fileprivate var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
