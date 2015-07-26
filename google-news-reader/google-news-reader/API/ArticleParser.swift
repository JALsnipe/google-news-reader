//
//  ArticleParser.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

struct ArticlePrototype {
    var title: String!
    var description: String!
    var imageURL: String? // can use placeholder
}

class ArticleParser: NSObject {
    
    var data: NSData!
    var parser: NSXMLParser!
    
    var element = ""
    var articles = [ArticlePrototype]()
    var articleTitle = ""
    var articleDescription = ""
    var articleImageURL = ""
    
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
            // next element, clear properties
            self.articleTitle = ""
            self.articleDescription = ""
            self.articleImageURL = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if self.element == "title" {
            self.articleTitle += string
        }
        
        if self.element == "description" {
            self.articleDescription += string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if !self.articleTitle.isEmpty && !self.articleDescription.isEmpty {
                
                let article = ArticlePrototype(title: self.articleTitle, description: self.self.stringByStrippingHTML(articleDescription), imageURL: "")
                
                self.articles.append(article)
                print(self.articleTitle)
            }
        }
    }
    
    func stringByStrippingHTML(input: String) -> String {
        
        let stringlength = input.characters.count
        var newString = ""
        
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive)
            
            newString = regex.stringByReplacingMatchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, stringlength), withTemplate: "")
            
            print(newString)
        } catch {
            print(error)
        }
        
        return newString
    }
}
