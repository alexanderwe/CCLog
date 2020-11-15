//
//  File.swift
//  
//
//  Created by Alexander Weiß on 14.11.20.
//

import Foundation
import XCTest
@testable import CCLogCore


final class TagQueryTests: XCTestCase {
    
    func testClosedRangeExample() throws {
        let stringQuery = "v1.0.0..v2.0.0"
        let taqQuery = try XCTUnwrap(TagQuery(data: stringQuery))
        
        XCTAssertEqual(taqQuery, .closed(start: "v1.0.0", end: "v2.0.0"))
    }
    
    func testRightOpenRangeExample() throws {
        let stringQuery = "v1.0.0.."
        let taqQuery = try XCTUnwrap(TagQuery(data: stringQuery))
        
        XCTAssertEqual(taqQuery, .rightOpen(start: "v1.0.0"))
    }
    
    func testLeftOpenRangeExample() throws {
        let stringQuery = "..v2.0.0"
        let taqQuery = try XCTUnwrap(TagQuery(data: stringQuery))
        
        XCTAssertEqual(taqQuery, .leftOpen(end: "v2.0.0"))
    }
    
    func testSingleRangeExample() throws {
        let stringQuery = "v2.0.0"
        let taqQuery = try XCTUnwrap(TagQuery(data: stringQuery))
        
        XCTAssertEqual(taqQuery, .single(tag: "v2.0.0"))
    }
    
    static var allTests = [
        ("testClosedRangeExample", testClosedRangeExample),
        ("testRightOpenRangeExample", testRightOpenRangeExample),
        ("testLeftOpenRangeExample", testLeftOpenRangeExample),
        ("testSingleRangeExample", testSingleRangeExample),
    ]
}
