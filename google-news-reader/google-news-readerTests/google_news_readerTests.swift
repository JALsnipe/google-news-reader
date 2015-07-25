//
//  google_news_readerTests.swift
//  google-news-readerTests
//
//  Created by Josh L on 7/24/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import XCTest
@testable import google_news_reader

class google_news_readerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFetchAllArticles() {
        XCTAssertNotNil(NetworkManager().fetchAllArticles())
    }
    
}
