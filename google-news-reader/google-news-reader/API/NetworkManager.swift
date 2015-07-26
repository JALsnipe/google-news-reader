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
    
    var localizedDescription: String {
        switch self {
        case .NetworkFailure:
            return "No Network Connection"
            
        case .ParsingError:
            return "Data Parsing Error"
            
        default:
            return "Unknown Error"
        }
    }
}

class NetworkManager: NSObject {

    func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: ErrorType?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: kGoogleNewsRSSURL)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            print("data: \(data)")
            print("response: \(response)")
            print("error: \(error)")
            
            if let parsedResponse = response as? NSHTTPURLResponse {
                
                if (data != nil) && (error == nil) && (parsedResponse.statusCode == kHTTPResponseStatusCodeSuccess) {
                    // good data, no error, good response status code
                    completion(data: data, error: nil)
                } else {
                    if error != nil {
                        // check error returned first
                        if let errorCode = error?.code {
                            switch errorCode {
                            case NSURLErrorNotConnectedToInternet:
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
    
    func parseAllArticleData(data: NSData, completion: (content: [ArticlePrototype]?, error: ErrorType?) -> Void) {
        
        let articleParser = ArticleParser(data: data)
        
        articleParser.parseDataWithCompletion { (success) -> Void in
            if success {
                completion(content: articleParser.articles, error: nil)
            } else {
                completion(content: nil, error: NetworkError.ParsingError)
            }
        }
    }
}