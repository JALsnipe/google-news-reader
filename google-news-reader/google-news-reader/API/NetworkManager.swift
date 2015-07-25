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
            
            completion(data: data, error: error)
        }.resume()
    }
    
    func parseAllArticleData(data: NSData, completion: (content: [String]?, error: NSError?) -> Void) {
        
        let articleParser = ArticleParser(data: data)
        
        articleParser.parseDataWithCompletion { (success) -> Void in
            if success {
                completion(content: articleParser.titles, error: nil)
            } else {
                completion(content: nil, error: nil)
            }
        }
    }
}