//
//  TagQuery.swift
//  
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import Parsing

// MARK: - TagQuery
enum TagQuery {
    case closed(start: String, end: String)
    case rightOpen(start: String)
    case leftOpen(end: String)
    case single(tag: String)
}

extension TagQuery {
    private static let parser: AnyParser<Substring, TagQuery> = {
        
        let closedRange = Parsers.NotEmpty(PrefixUpTo<Substring>(".."))
            .skip(StartsWith(".."))
            .take(Parsers.NotEmpty(Parsers.Rest()))
            .map { (start, end) -> TagQuery in
                TagQuery.closed(start: String(start), end: String(end))
            }
            .eraseToAnyParser()
        
        let rightOpenRange = Parsers.NotEmpty(PrefixUpTo<Substring>(".."))
            .skip(StartsWith(".."))
            .map { start in
                TagQuery.rightOpen(start: String(start))
            }
            .eraseToAnyParser()
        
        let leftOpenRange = Parsers.Skip(StartsWith(".."))
            .take(Parsers.NotEmpty(Parsers.Rest()))
            .map { end in
                TagQuery.leftOpen(end: String(end))
            }
            .eraseToAnyParser()
        
        let singleTagRange = Parsers.Rest<Substring>()
            .map { tag in
                TagQuery.single(tag: String(tag))
            }
            .eraseToAnyParser()
        
        return Parsers.OneOfMany(closedRange, rightOpenRange, leftOpenRange, singleTagRange).eraseToAnyParser()
        
    }()
    
    public init?(data: String) {
        guard let match = TagQuery.parser.parse(data[...]) else {
            return nil
        }
        
        self = match
    }
}

// MARK: Equatable
extension TagQuery: Equatable {
    static func ==(lhs: TagQuery, rhs: TagQuery) -> Bool {
        switch (lhs, rhs) {
        case (let .closed(lhsStart, lhsEnd), let .closed(rhsStart, rhsEnd)):
            return lhsStart == rhsStart && lhsEnd == rhsEnd
        case (let .rightOpen(lhsStart), let .rightOpen(rhsStart)):
            return lhsStart == rhsStart
        case (let .leftOpen(lhsEnd), let .leftOpen(rhsEnd)):
            return lhsEnd == rhsEnd
        case (let .single(lhsTag), let .single(rhsTag)):
            return lhsTag == rhsTag
        default:
            return false
        }
    }
}

// MARK: - Parser extension
extension Parsers {
    
    public struct NotEmpty<A>: Parser
    where
        A: Parser,
        A.Input == Substring,
        A.Output == Substring
    {
        public let parser: A
        
        @inlinable
        public init(_ parser: A) {
            self.parser = parser
        }
        
        @inlinable
        @inline(__always)
        public func parse(_ input: inout A.Input) -> A.Output? {
            return parser
                .flatMap { $0.isEmpty ? Parsers.Fail().eraseToAnyParser() : Parsers.Always($0).eraseToAnyParser()  }
                .parse(&input)
        }
        
    }
}
