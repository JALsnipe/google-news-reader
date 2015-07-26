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
    
    func testFetchAllArticles() {
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            XCTAssertNotNil(data)
            
            if error != nil {
                XCTFail("fetchAllArticles should not return an error")
            }
            
        }
    }
    
    func testParseAllArticleData() {
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            XCTAssertNotNil(data)
            
            guard let parsedData = data as? NSData else {
                XCTFail()
                return
            }
            
            NetworkManager().parseAllArticleData(parsedData, completion: { (content, error) -> Void in
                
                if error != nil {
                    XCTFail("parsing article data failed")
                }
                
                if let unwrappedContent = content as [ArticlePrototype]! {
                    if unwrappedContent.isEmpty {
                        XCTFail("parseAllArticleData should return a non-empty array of Article Prototypes")
                    }
                }
            })
        }
    }
    
    func testParsingWithBadData() {
        NetworkManager().parseAllArticleData(NSData()) { (content, error) -> Void in
            if error == nil {
                XCTFail("parseAllArticleData should fail with bad data")
            }
        }
    }
    
}
