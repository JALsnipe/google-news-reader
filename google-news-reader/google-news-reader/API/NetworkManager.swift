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

    // The intital entry point for fetching articles
    // This method takes make a network request to the Google News RSS feed and returns an NSData object and/or a custom NetworkError ErrorType object I have defined above
    func fetchAllArticlesWithCompletion(completion: (data: AnyObject?, error: ErrorType?) -> Void) {
        
        let request = NSURLRequest(URL: NSURL(string: kGoogleNewsRSSURL)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
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
    
    // This method takes in an NSData object and runs it through my parser class to parse the XML
    // It returns an array of ArticlePrototype structs (the prototype object used to create my Article NSManagedObject, and/or a ParsingError
    func parseAllArticleData(data: NSData, completion: (content: [ArticlePrototype]?, error: ErrorType?) -> Void) {
        
        let articleParser = ArticleParser(data: data)
        
        articleParser.parseDataWithCompletion { (success) -> Void in
            if success {
                
                // try core data
                CoreDataManager().cacheFetchedArticles(articleParser.articles)
                
                completion(content: articleParser.articles, error: nil)
            } else {
                completion(content: nil, error: NetworkError.ParsingError)
            }
        }
    }
    
    // This method takes in an array of ArticlePrototype objects, fetches the image for each object, and retuns are new array of ArticlePrototype objects with image properties
    func downloadImagesForArticles(articles: [ArticlePrototype], completion: (articles: [ArticlePrototype]) -> Void) {
        
        if articles.isEmpty {
            completion(articles: articles)
        }
        
        var articlesWithImages = [ArticlePrototype]()
        
        var index = 0
        
        for var article in articles {
            self.fetchImageFromURL(article.imageURL, completion: { (image) -> Void in
                article.image = image
                
                articlesWithImages.append(article)
                
                index++;
                
                if index == articles.count {
                    completion(articles: articlesWithImages)
                }
                
            })
        }
    }
    
    // This method is used internally by downloadImagesForArticles
    // It performs the web request to fetch the data associated with an image URL, and return a UIIimage
    func fetchImageFromURL(url: String, completion:(image: UIImage?) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if data != nil {
                
                if let unwrappedData = data as NSData! {
                    completion(image: UIImage(data: unwrappedData))
                }
            } else {
                completion(image: nil)
            }
        }.resume()
    }
}