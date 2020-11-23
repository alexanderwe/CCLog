//
//  SemanticVersionTests.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import XCTest
@testable import SemanticVersioning
import ParserCombinator

final class SemanticVersionTests: XCTestCase {
    
    func testCore() throws {
        let semverString = "1.0.0"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
    }
    
    
    func testPreReleaseIdentifiers1() throws {
        let semverString = "1.0.0-alpha"
        
        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 1)
        XCTAssertEqual(version.preReleaseIdentifiers[0], "alpha")
    }
    
    func testPreReleaseIdentifiers2() throws {
        let semverString = "1.0.0-alpha.1"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 2)
        XCTAssertEqual(version.preReleaseIdentifiers[0], "alpha")
        XCTAssertEqual(version.preReleaseIdentifiers[1], "1")
    }
    
    func testPreReleaseIdentifiers3() throws {
        let semverString = "1.0.0-x.7.z.92"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 4)
        XCTAssertEqual(version.preReleaseIdentifiers[0], "x")
        XCTAssertEqual(version.preReleaseIdentifiers[1], "7")
        XCTAssertEqual(version.preReleaseIdentifiers[2], "z")
        XCTAssertEqual(version.preReleaseIdentifiers[3], "92")
    }
    
    func testPreReleaseIdentifiers4() throws {
        let semverString = "1.0.0-x-y-z.-"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 2)
        XCTAssertEqual(version.preReleaseIdentifiers[0], "x-y-z")
        XCTAssertEqual(version.preReleaseIdentifiers[1], "-")
    }
    
    func testBuildIdentifiers1() throws {
        let semverString = "1.0.0+20130313144700"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 1)
        XCTAssertEqual(version.buildIdentifiers[0], "20130313144700")
    }
    
    func testBuildIdentifiers2() throws {
        let semverString = "1.0.0+exp.sha.5114f85"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 3)
        XCTAssertEqual(version.buildIdentifiers[0], "exp")
        XCTAssertEqual(version.buildIdentifiers[1], "sha")
        XCTAssertEqual(version.buildIdentifiers[2], "5114f85")
    }
    
    func testBuildIdentifiers3() throws {
        let semverString = "1.0.0+21AF26D3--117B344092BD"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 0)
        
        XCTAssertEqual(version.buildIdentifiers.count, 1)
        XCTAssertEqual(version.buildIdentifiers[0], "21AF26D3--117B344092BD")
    }
    
    func testPreAndBuildIdentifiers() throws {
        let semverString = "1.0.0-alpha+001"

        let version = try XCTUnwrap(SemanticVersion(data: semverString))
        
        XCTAssertEqual(version.major, 1)
        XCTAssertEqual(version.minor, 0)
        XCTAssertEqual(version.patch, 0)
        
        XCTAssertEqual(version.preReleaseIdentifiers.count, 1)
        XCTAssertEqual(version.preReleaseIdentifiers[0], "alpha")
        
        XCTAssertEqual(version.buildIdentifiers.count, 1)
        XCTAssertEqual(version.buildIdentifiers[0], "001")
    }
    
    static var allTests = [
        ("testCore", testCore),
        ("testPreReleaseIdentifiers1", testPreReleaseIdentifiers1),
        ("testPreReleaseIdentifiers2", testPreReleaseIdentifiers2),
        ("testPreReleaseIdentifiers3", testPreReleaseIdentifiers3),
        ("testPreReleaseIdentifiers4", testPreReleaseIdentifiers4),
        ("testBuildIdentifiers1", testBuildIdentifiers1),
        ("testBuildIdentifiers2", testBuildIdentifiers2),
        ("testBuildIdentifiers3", testBuildIdentifiers3),
        ("testPreAndBuildIdentifiers", testPreAndBuildIdentifiers)
    ]
}
