//
//  ConventionalCommitsFooterTests.swift
//  
//
//  Created by Alexander Weiß on 15.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommits

/// Tests related to parsing footers of a conventional commit message
final class ConventionalCommitsFooterTests: XCTestCase {
    
    func testSingleBreakingChangeFooterParsing() throws {
        
        let footerMessage = "BREAKING CHANGE: refactor to use JavaScript features not available in Node 6."
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "BREAKING CHANGE")
        XCTAssertEqual(footer.value, "refactor to use JavaScript features not available in Node 6.")
        XCTAssertEqual(footer.isBreaking, true)
    }
    
    func testSingleColonSeperatedFooterParsing() throws {
        
        let footerMessage = "Reviewed-by: Z"
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "Reviewed-by")
        XCTAssertEqual(footer.value, "Z")
        XCTAssertEqual(footer.isBreaking, false)
    }
    
    func testSingleHashtagSeperatedFooterParsing() throws {
        
        let footerMessage = "Refs #133"
        let footer = try XCTUnwrap(ConventionalCommit.Footer(data: footerMessage))
        
        XCTAssertEqual(footer.wordToken, "Refs")
        XCTAssertEqual(footer.value, "133")
        XCTAssertEqual(footer.isBreaking, false)
    }
    
    static var allTests = [
        ("testSingleBreakingChangeFooterParsing", testSingleBreakingChangeFooterParsing),
        ("testSingleColonSeperatedFooterParsing", testSingleColonSeperatedFooterParsing),
        ("testSingleHashtagSeperatedFooterParsing", testSingleHashtagSeperatedFooterParsing),
    ]
}
