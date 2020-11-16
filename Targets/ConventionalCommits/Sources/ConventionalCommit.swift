//
//  File.swift
//  
//
//  Created by Alexander Weiß on 17.10.20.
//

import ParserCombinator

public struct ConventionalCommit {
   
    
    
    public let header: Header
    public let footers: [Footer]?
    
    
    
    private static let parser: Parser<Substring, ConventionalCommit> = {
        let header = ConventionalCommit.Header.parser
        let footer = ConventionalCommit.Footer.parser
        
        
        return header
            //.skip(Parser<Substring, Substring>.prefix(while: { $0.isNewline }))
            .take(footer.zeroOrMore(separatedBy: .prefix("\n")))
            .map { header, footers in
               return ConventionalCommit(header: header, footers: footers)
            }
    }()
    
    public init?(data: String) {
        guard let match = ConventionalCommit.parser.run(data[...]).match else {
            return nil
        }
        
        self = match
    }
    
    internal init(header: ConventionalCommit.Header, footers: [ConventionalCommit.Footer]?) {
        self.header = header
        self.footers = footers
    }
}

extension ConventionalCommit {
    public struct Header {
        
        public let type: String
        public let scope: String?
        public let breaking: Bool
        public let description: String
        
        static let parser: Parser<Substring, Header> = {
            let anyScope = Parser<Substring, Substring>.prefix(while: {  $0 != "(" && $0 != ")" && !$0.isNewline })
                .flatMap { $0.isEmpty ? .never : Parser.always($0) }
            
            let anyLetter = Parser<Substring, Substring>.prefix(while: { $0.isLetter })
                .flatMap { $0.isEmpty ? .never : Parser.always($0) }

            let anyCharacter = Parser<Substring, Substring>.prefix(while: { $0.isLetter || $0.isWhitespace || $0.isSymbol || $0.isNumber })
                .flatMap { $0.isEmpty ? .never : Parser.always($0) }

            
            let isBreaking = Parser<Substring, Void?>.optional(.prefix("!"))
                .flatMap { $0 != nil ? .always(true) :  .always(false)}
            
            let type = anyLetter
            
            let scope = Parser.skip("(")
                .take(anyScope)
                .skip(")")
            
            return type
                .take(.optional(scope))
                .take(isBreaking)
                .skip(": ")
                .take(anyCharacter.map(String.init))
                .map { type, scope, isBreaking, description in
                    Header(
                        type: String(type),
                        scope: scope == nil ? nil: String(scope!),
                        breaking: isBreaking,
                        description: description
                    )
                }
        }()
        
        public init?(data: String) {
            guard let match = Header.parser.run(data[...]).match else {
                return nil
            }
            
            self = match
        }
        
        internal init(type: String, scope: String?, breaking: Bool, description: String) {
            self.type = type
            self.scope = scope
            self.breaking = breaking
            self.description = description
        }
    }
}



// MARK: - Footer
extension ConventionalCommit {
    public struct Footer {
       
        public let wordToken: String
        public let value: String
        public let isBreaking: Bool
        
        static let parser: Parser<Substring, Footer> = {
           
            let breakingWordToken = Parser<Substring, Void>.prefix("BREAKING CHANGE").map { _ in "BREAKING CHANGE"[...] }
            let regularWordToken = Parser<Substring, Substring>.prefix(while: { $0.isLetter || $0 == "-" })
            
            let colonSeperator = Parser<Substring, Void>.prefix(": ")
            let hashTagSeperator = Parser<Substring, Void>.prefix(" #")
            
            let footer: Parser<Substring, Footer> =  Parser<Substring, Substring>.oneOf([breakingWordToken, regularWordToken])
                .skip(.oneOf([colonSeperator, hashTagSeperator]))
                .take(.prefix(while: { !$0.isNewline }))
                .map { wordToken, value in
                    return Footer(wordToken: String(wordToken), value: String(value), isBreaking: String(wordToken) == "BREAKING CHANGE")
                }
            return footer
        }()
        
        
        public init?(data: String) {
            guard let match = Footer.parser.run(data[...]).match else {
                return nil
            }
            
            self = match
        }
        
        internal init(wordToken: String, value: String, isBreaking: Bool) {
            self.wordToken = wordToken
            self.value = value
            self.isBreaking = isBreaking
        }
    }
}
