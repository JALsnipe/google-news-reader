//
//  NetworkManager.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

enum NetworkError: ErrorType {
    case NetworkFailure
    case ParsingError
    case UnknownError
}

class NetworkManager: NSObject {

    func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: ErrorType?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: "http://news.google.com/?output=rss")!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            print("data: \(data)")
            print("response: \(response)")
            print("error: \(error)")
            
            if let parsedResponse = response as? NSHTTPURLResponse {
                
                if (data != nil) && (error == nil) && (parsedResponse.statusCode == 200) {
                    // good data, no error, good response status code
                    completion(data: data, error: nil)
                } else {
                    if error != nil {
                        // check error returned first
                        if let errorCode = error?.code {
                            switch errorCode {
                            case 1009:
                                completion(data: nil, error: NetworkError.NetworkFailure)
                                
                            default:
                                completion(data: nil, error: NetworkError.UnknownError)
                            }
                        }
                    } else {
                        // non-success status codes and catch all
                        completion(data: nil, error: NetworkError.UnknownError)
                    }
                }
            }
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