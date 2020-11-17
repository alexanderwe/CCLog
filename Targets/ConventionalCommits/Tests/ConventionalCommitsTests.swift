//
//  ConventionalCommitsTests.swift
//  
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommits
import ParserCombinator


final class ConventionalCommitsTests: XCTestCase {
    
    func testNoBody() throws {
        let commitMessage = """
        fix: Fix iOS and tvOS versions
        """

        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
        XCTAssertEqual(commit.header.type, "fix")
        XCTAssertEqual(commit.header.description, "Fix iOS and tvOS versions")
        XCTAssertNil(commit.header.scope)
        XCTAssertEqual(commit.header.breaking, false)
        XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 0)
    }
    
    
    func testDescriptionAndBreakingChangeFooter() throws {
        
        let commitMessage = """
        feat: allow provided config object to extend other configs

        Reviewed-by: Z
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
        XCTAssertEqual(commit.header.type, "feat")
        XCTAssertEqual(commit.header.description, "allow provided config object to extend other configs\n")
        XCTAssertNil(commit.header.scope)
        XCTAssertEqual(commit.header.breaking, false)
        
        //TODO: Decide what to do with the body
        //XCTAssertNil(commit.body)
        XCTAssertEqual(commit.footers.count, 1)
    }
    
    func testHeaderWithFooter() throws {
        
        let commitMessage = """
        refactor!: drop support for Node 6

        Reviewed-by: Z
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
       
    }
    
    
    func testMultiParagraphBodyAndMultipleFooters() throws {
        
        
        let commitMessage = """
        fix: correct minor typos in code

        see the issue for details

        on typos fixed.

        Reviewed-by: Z
        Refs #133
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
    }
   
}
