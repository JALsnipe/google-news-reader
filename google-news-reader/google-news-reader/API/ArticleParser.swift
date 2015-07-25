//
//  ArticleParser.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

class ArticleParser: NSObject {
    
    var data: NSData!
    var parser: NSXMLParser!
    
    var element = ""
    var titles = [String]()
    var title = ""
    
    convenience init (data: NSData) {
        self.init()
        
        self.data = data
        self.parser = NSXMLParser(data: data)
        self.parser.delegate = self
    }
    
    func parseDataWithCompletion(completion: (success: Bool) -> Void) {
        completion(success: self.parser.parse())
    }
}

// MARK: NSXMLParserDelegate Methods

extension ArticleParser: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.element = elementName
        
        if self.element == "item" {
            // next element, clear title
            self.title = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if self.element == "title" {
            self.title += string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if !self.title.isEmpty {
                self.titles.append(self.title)
                print(self.title)
            }
        }
    }
}
