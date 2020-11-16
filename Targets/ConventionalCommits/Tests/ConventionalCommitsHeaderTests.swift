//
//  ConventionalCommitsHeaderTests.swift
//  
//
//  Created by Alexander Weiß on 16.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommits

/// Tests related to parsing footers of a conventional commit message
final class ConventionalCommitsHeaderTests: XCTestCase {
    
    func testHeaderNoScope() throws {
        let commitMessage = """
        fix: Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testHeaderWithScope() throws {
        let commitMessage = """
        fix(ci): Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, false)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testHeaderBreakingChange() throws {
        let commitMessage = """
        fix!: Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertNil(commit.scope)
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testHeaderBreakingChangeWithScope() throws {
        let commitMessage = """
        fix(ci)!: Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit.Header(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.breaking, true)
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    func testHeaderMissingDescription() throws {
        let commitMessage = """
        fix(ci)!:
        """
        
        XCTAssertNil(ConventionalCommit.Header(data: commitMessage))
    }
    
    func testHeaderMissingType() throws {
        let commitMessage = """
        : Fix iOS and tvOS versions
        """
        
        XCTAssertNil(ConventionalCommit.Header(data: commitMessage))
    }
    
    static var allTests = [
        ("testHeaderNoScope", testHeaderNoScope),
        ("testHeaderWithScope", testHeaderWithScope),
        ("testHeaderBreakingChange", testHeaderBreakingChange),
        ("testHeaderBreakingChangeWithScope", testHeaderBreakingChangeWithScope),
        ("testHeaderMissingDescription", testHeaderMissingDescription),
        ("testHeaderMissingType", testHeaderMissingType),
    ]
}

