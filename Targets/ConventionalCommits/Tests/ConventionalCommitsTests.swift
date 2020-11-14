//
//  File.swift
//  
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import XCTest
@testable import ConventionalCommits


final class ConventionalCommitsTests: XCTestCase {
    
    func testConventionalCommitParsing() throws {
        let commitMessage = """
        fix(ci): Fix iOS and tvOS versions
        """
        
        let commit = try XCTUnwrap(ConventionalCommit(data: commitMessage))
        
        XCTAssertEqual(commit.type, "fix")
        XCTAssertEqual(commit.scope, "ci")
        XCTAssertEqual(commit.description, "Fix iOS and tvOS versions")
    }
    
    
    static var allTests = [
        ("testConventionalCommitParsing", testConventionalCommitParsing),
    ]
    
}
