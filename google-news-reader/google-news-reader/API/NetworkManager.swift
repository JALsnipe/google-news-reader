//
//  NetworkManager.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {

    func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: NSError?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: "http://news.google.com/?output=rss")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            print(data)
            print(response)
            print(error)
            
            completion(data: data, error: error)
        }.resume()
    }
    
    func parseAllArticleData(data: NSData) {
        let parser = NSXMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            print("success")
        } else {
            print("error")
        }
    }
}

extension NetworkManager: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        print("elementName: \(elementName)")
        print("namespaceURI: \(namespaceURI)")
        print("qName: \(qName)")
        print("attributeDict: \(attributeDict)")
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        print("foundCharacters: \(string)")
    }
}