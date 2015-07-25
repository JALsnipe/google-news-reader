//
//  NetworkManager.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    var element = ""
    var titles = [String]()
    var title = ""

    func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: NSError?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: "http://news.google.com/?output=rss")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//            print(data)
//            print(response)
//            print(error)
            
            completion(data: data, error: error)
        }.resume()
    }
    
    func parseAllArticleData(data: NSData, completion: (content: [String], error: NSError?) -> Void) {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            print("success")
            completion(content: self.titles, error: nil)
        } else {
            print("error")
        }
    }
}

extension NetworkManager: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
//        print("elementName: \(elementName)")
//        print("namespaceURI: \(namespaceURI)")
//        print("qName: \(qName)")
//        print("attributeDict: \(attributeDict)")
        
        self.element = elementName
        
        if self.element == "item" {
            // new element, clear title
            self.title = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
//        print("foundCharacters: \(string)")
        if self.element == "title" {
            self.title += string
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if !self.title.isEmpty {
                self.titles.append(self.title)
            }
        }
    }
}