//
//  TagQuery.swift
//  
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import ParserCombinator

// MARK: - TagQuery
enum TagQuery {
    case closed(start: String, end: String)
    case rightOpen(start: String)
    case leftOpen(end: String)
    case single(tag: String)
}

extension TagQuery {
    private static let parser: Parser<Substring, TagQuery> = {
    
        let closedRange = Parser<Substring, Substring>.notEmpty(.prefix(upTo: ".."))
                .skip("..")
                .take(.notEmpty(.prefix(while: { _ in true })))
                .map {start, end in
                    TagQuery.closed(start: String(start), end: String(end))
                }
        
        let rightOpenRange = Parser<Substring, Substring>.notEmpty(.prefix(upTo: ".."))
            .skip("..")
            .map { start in
                TagQuery.rightOpen(start: String(start))
            }
        
        let leftOpenRange = Parser.skip("..")
            .take(.notEmpty(.prefix(while: { _ in true })))
            .map { end in
                TagQuery.leftOpen(end: String(end))
            }
        
        let singleTagRange = Parser<Substring, Substring>.prefix(while: { _ in true})
            .map { tag in
                TagQuery.single(tag: String(tag))
            }
        
        return Parser.oneOf([closedRange, rightOpenRange, leftOpenRange, singleTagRange])
    
    }()
    
    public init?(data: String) {
        guard let match = TagQuery.parser.run(data[...]).match else {
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
extension Parser where Input == Substring, Output == Substring {
    public static func notEmpty(_ p: Self) -> Parser<Input, Output> {
        p.flatMap { $0.isEmpty ? .never : Parser.always($0) }
    }
}
