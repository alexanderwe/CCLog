//
//  SemanticVersion.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import ParserCombinator

// MARK: - SemanticVersion
struct SemanticVersion {
  
    let core: Core
    let preReleaseIdentifiers: [String]
    let buildIdentifiers: [String]
    
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
