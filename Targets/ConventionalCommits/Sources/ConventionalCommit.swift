//
//  ConventionalCommit.swift
//  
//
//  Created by Alexander Weiß on 17.10.20.
//

import ParserCombinator

// MARK: - Conventional Commit
public struct ConventionalCommit {
   
    private let _header: Header
    private let _body: String?
    private let _footers: [Footer]
    
    
    public var type: String {
        return _header.type
    }
    
    public var scope: String? {
        return _header.scope
    }
    
    public var description: String {
        return _header.description
    }
    
    public var isBreaking: Bool {
        return _header.breaking || _footers.map { $0.isBreaking }.contains(true)
    }
    
    public var body: String? {
        return _body
    }
    
    public var footers: [Footer] {
        return _footers
    }
}

// MARK: Parser
extension ConventionalCommit {
    
    private static let parser: Parser<Substring, ConventionalCommit> = {
        
        // When the body is empty the body will be nil
        func convertSubstringToBody(substring: Substring?) -> String? {
            if substring == nil {
                return nil
            } else {
                let str = String(substring!)
                
                if (str.isEmpty) {
                    return nil
                }
                
                return str
            }
        }
        
        let headerParser = ConventionalCommit.Header.parser
        let singleFooterParser = ConventionalCommit.Footer.parser
        
        //TODO: maybe try to use something else to find the
        //beginning of the footers?
  
        // These regexes try to find the beginning of the footers section:
        // 1. BREAKING CHANGE token after a new line
        // 2. BREAKING CHANGE token without a new line
        // 3. BREAKING-CHANGE token after a new line
        // 4. BREAKING-CHANGE token without a new line
        // 5. <Any hypen seperatable word>:<space> or <Any hypen seperatable word><space>#  after a new line
        // 6. <Any hypen seperatable word>:<space> or <Any hypen seperatable word><space>#  without a new line
        let bodyParser = Parser<Substring, Void>.skip("\n")
            .take(.oneOf([Parser<Substring,Substring>.prefix(upToRegex: "[\\n]?(BREAKING CHANGE|BREAKING-CHANGE)"), //1,2,3,4
                          Parser<Substring,Substring>.prefix(upToRegex: "[\\n]?(((?=\\S*['-]?)([a-zA-Z'-]+):\\s)|((?=\\S*['-]?)([a-zA-Z'-]+)\\s\\#))") //5,6
            ]))
        
        let footersParser = Parser<Substring, Void?>.skip(.optional("\n"))
            .take(singleFooterParser.zeroOrMore(separatedBy: .prefix("\n")))
        
        
        return headerParser
            .take(.optional(bodyParser))
            .take(.optional(footersParser))
            .map { header, body, footers in
                ConventionalCommit(header: header,
                                   body: convertSubstringToBody(substring: body)?.trimmingCharacters(in: .newlines),
                                   footers: footers == nil ? []: footers!
                )
            }
    }()
    
    public init?(data: String) {
        guard let match = ConventionalCommit.parser.run(data[...]).match else {
            return nil
        }
        
        self = match
    }
    
    internal init(header: ConventionalCommit.Header, body: String?, footers: [ConventionalCommit.Footer]) {
        self._header = header
        self._body = body
        self._footers = footers
    }
}

// MARK: - Header
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
                .take(
                    Parser<Substring, Substring>.oneOf([.prefix(through: "\n"), .rest])
                        .map(String.init))
                .map { type, scope, isBreaking, description in
                    
                    //TODO: Trim the \n at the end of the description
                    Header(
                        type: String(type),
                        scope: scope == nil ? nil: String(scope!),
                        breaking: isBreaking,
                        description: description.trimmingCharacters(in: .newlines)
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
            let breakingWordHyphenToken = Parser<Substring, Void>.prefix("BREAKING-CHANGE").map { _ in "BREAKING-CHANGE"[...] }
            let regularWordToken = Parser<Substring, Substring>.prefix(while: { $0.isLetter || $0 == "-" })
            
            let colonSeperator = Parser<Substring, Void>.prefix(": ")
            let hashTagSeperator = Parser<Substring, Void>.prefix(" #")
            
            let footer: Parser<Substring, Footer> =  Parser<Substring, Substring>.oneOf([breakingWordToken, regularWordToken])
                .skip(.oneOf([colonSeperator, hashTagSeperator]))
                .take(.prefix(while: { !$0.isNewline }))
                .map { wordToken, value in
                    return Footer(wordToken: String(wordToken), value: String(value), isBreaking: String(wordToken) == "BREAKING CHANGE" || String(wordToken) == "BREAKING-CHANGE")
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
