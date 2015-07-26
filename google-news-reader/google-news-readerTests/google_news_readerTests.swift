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
        
        let expectation = self.expectationWithDescription("fetchAllArticles should return valid NSData")
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            XCTAssertNotNil(data)
            expectation.fulfill()
            
            if error != nil {
                XCTFail("fetchAllArticles should not return an error")
            }
            
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testParseAllArticleData() {
        
        let expectation = self.expectationWithDescription("fetchAllArticles should return valid NSData and parseAllArticleData should be able to parse that data")
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
                    } else {
                        // good data
                        expectation.fulfill()
                    }
                }
            })
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testParsingWithBadData() {
        
        let expectation = self.expectationWithDescription("parseAllArticleData should return an error with bad data")
        
        NetworkManager().parseAllArticleData(NSData()) { (content, error) -> Void in
            if error == nil {
                XCTFail("parseAllArticleData should fail with bad data")
            } else {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testDownloadImagesForArticlesWithEmptyList() {
        
        let expectation = self.expectationWithDescription("downloadImagesForArticles should return an empty output on an empty input")
        
        NetworkManager().downloadImagesForArticles([]) { (articles) -> Void in
            if !articles.isEmpty {
                XCTFail("Output should be empty with an empty imput")
            } else {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchImageFromURL() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return an image from a valid url")
        
        let testImageStr = "http://t1.gstatic.com/images?q=tbn:ANd9GcTjAzyVSXcKCRMds1AmH1AcQyGZm6As6TQqKHkYJhBHyQe3BQgqWXvLqioBRdlsR31U-cGJj7k"
        
        NetworkManager().fetchImageFromURL(testImageStr) { (image) -> Void in
            XCTAssertNotNil(image, "Image returned from sample URL should not be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchImageWithBadUrl() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return nil from a non-image url")
        
        let testImageStr = "http://www.google.com/"
        
        NetworkManager().fetchImageFromURL(testImageStr) { (image) -> Void in
            print(image)
            XCTAssertNil(image, "Image returned from non-image URL should be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchImageWithEmptyUrl() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return nil from a non-image url")
        
        NetworkManager().fetchImageFromURL("") { (image) -> Void in
            XCTAssertNil(image, "Image returned from empty URL should be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
