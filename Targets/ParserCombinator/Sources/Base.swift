//
//  Parser.swift
//  
//
//  Created by Alexander Weiß on 18.10.20.
//

import Foundation


// Credit: https://www.pointfree.co


// MARK: - Base
public struct Parser<Input, Output> {
    public let run: (inout Input) -> Output?
}

extension Parser {
    public func run(_ input: Input) -> (match: Output?, rest: Input) {
        var input = input
        let match = self.run(&input)
        return (match, input)
    }
}

extension Parser {
    public static func always(_ output: Output) -> Self {
        Self { _ in output }
    }
    
    public static var never: Self {
        Self { _ in nil }
    }
}

// Optional
extension Parser {
  public static func optional<A>(
    _ parser: Parser<Input, A>
  ) -> Self where Output == A? {
    .init { input in
      .some(parser.run(&input))
    }
  }
}

// MARK: - Parser amount
extension Parser {
    public static func oneOf(_ ps: [Self]) -> Self {
        .init { input in
            for p in ps {
                if let match = p.run(&input) {
                    return match
                }
            }
            return nil
        }
    }
    
    static func oneOf(_ ps: Self...) -> Self {
        self.oneOf(ps)
    }
}


extension Parser {
    public func zeroOrMore(
        separatedBy separator: Parser<Input, Void> = .always(())
    ) -> Parser<Input, [Output]> {
        Parser<Input, [Output]> { input in
            var rest = input
            var matches: [Output] = []
            while let match = self.run(&input) {
                rest = input
                matches.append(match)
                if separator.run(&input) == nil {
                    return matches
                }
            }
            input = rest
            return matches
        }
    }
}


// MARK: - Combinators

// MARK: Map
extension Parser {
    public func map<NewOutput>(_ f: @escaping (Output) -> NewOutput) -> Parser<Input, NewOutput> {
        .init { input in
            self.run(&input).map(f)
        }
    }
}

// MARK: FlatMap
extension Parser {
    public func flatMap<NewOutput>(
        _ f: @escaping (Output) -> Parser<Input, NewOutput>
    ) -> Parser<Input, NewOutput> {
        .init { input in
            let original = input
            let output = self.run(&input)
            let newParser = output.map(f)
            guard let newOutput = newParser?.run(&input) else {
                input = original
                return nil
            }
            return newOutput
        }
    }
}

// MARK: zip
public func zip<Input, Output1, Output2>(
    _ p1: Parser<Input, Output1>,
    _ p2: Parser<Input, Output2>
) -> Parser<Input, (Output1, Output2)> {
    
    .init { input -> (Output1, Output2)? in
        let original = input
        guard let output1 = p1.run(&input) else { return nil }
        guard let output2 = p2.run(&input) else {
            input = original
            return nil
        }
        return (output1, output2)
    }
}

// MARK: take and skip
extension Parser {
    
    public func skip<B>(_ p: Parser<Input, B>) -> Self {
        zip(self, p).map {a, _ in a}
    }
    
    public func take<NewOutput>(_ p: Parser<Input, NewOutput>) -> Parser<Input, (Output, NewOutput)> {
        zip(self, p)
    }
}


extension Parser {
    
    //(Parser<(A, B)>, Parser<C>) -> Parser<(A, B, C)>
    public func take<A, B, C>(_ p: Parser<Input, C>) -> Parser<Input, (A, B, C)> where Output == (A, B) {
        zip(self, p).map { ab, c in
            (ab.0, ab.1, c)
        }
    }
    
    //(Parser<(A, B, C)>, Parser<D>) -> Parser<(A, B, C, D)>
    public func take<A, B, C, D>(_ p: Parser<Input, D>) -> Parser<Input, (A, B, C, D)> where Output == (A, B, C) {
        zip(self, p).map { abc, d in
            (abc.0, abc.1, abc.2, d)
        }
    }
    
}

extension Parser {
    public static func skip(_ p: Self) -> Parser<Input, Void> {
        p.map {_ in () }
    }
}

extension Parser where Output == Void {
    
    public func take<A>(_ p: Parser<Input, A>) -> Parser<Input, A> {
        zip(self, p).map {_, a in a}
    }
}
