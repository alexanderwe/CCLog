//
//  File.swift
//  
//
//  Created by Alexander Weiß on 17.10.20.
//

import ParserCombinator

public struct ConventionalCommit {
   
    public let type: String
    public let scope: String?
    public let description: String
    public let body: String?
    public let breaking: Bool
    public let footer: String?
    
    
    private static let parser: Parser<ConventionalCommit> = {
       
        let anyScope = Parser.prefix(while: {  $0 != "(" && $0 != ")" && !$0.isNewline })
            .flatMap { $0.isEmpty ? .never : Parser.always($0) }
        
        let anyLetter = Parser.prefix(while: { $0.isLetter })
            .flatMap { $0.isEmpty ? .never : Parser.always($0) }

        let anyCharacter = Parser.prefix(while: { $0.isLetter || $0.isWhitespace || $0.isSymbol })
            .flatMap { $0.isEmpty ? .never : Parser.always($0) }

        let isBreaking = Parser.prefix("!").optional
            .flatMap { $0 != nil ? .always(true) :  .always(false)}
        
        let type = anyLetter
        
        let scope = anyScope.between(a: "(", b: ")")
        
        return zip(type, scope.optional, isBreaking, ": ", anyCharacter)
            .map { type, scope, isBreaking,  _, description in
                ConventionalCommit(
                    type: String(type),
                    scope: scope == nil ? nil: String(scope!),
                    description: String(description),
                    body: nil,
                    breaking: isBreaking,
                    footer: nil
                )
          }
    }()
    
    public init?(data: String) {
        guard let match = ConventionalCommit.parser.run(data).match else {
            return nil
        }
        
        self = match
    }
    
    internal init(type: String, scope: String?, description: String, body: String?, breaking: Bool, footer: String?) {
        self.type = type
        self.scope = scope
        self.description = description
        self.body = body
        self.breaking = breaking
        self.footer = footer
    }
}
