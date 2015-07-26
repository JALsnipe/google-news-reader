//
//  NetworkManager.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit
import CoreData

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
                
                // try core data
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                var managedArray = [Article]()
                
                for articleProto in articleParser.articles {
                    let managedArticle = Article(prototype: articleProto, inManagedObjectContext: managedContext)
                    managedArray.append(managedArticle)
                }
                
                // save
                
                
                do {
                    try managedContext.save()
                } catch {
                    print("Error: \(error)")
                }
                
                // try fetch
                // For debugging only
//                let fetchRequest = NSFetchRequest(entityName:"Article")
//                
//                do {
//                    let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
//                    
//                    print(fetchedResults)
//                } catch {
//                    print("Error: \(error)")
//                }
                
                // TODO: If CoreData save fails, throw error or return articles without caching
                
                completion(content: articleParser.articles, error: nil)
            } else {
                completion(content: nil, error: NetworkError.ParsingError)
            }
        }
    }
    
    func downloadImagesForArticles(articles: [ArticlePrototype], completion: (articles: [ArticlePrototype]) -> Void) {
        
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
    
    func fetchImageFromURL(url: String, completion:(image: UIImage?) -> Void) {
        let request = NSURLRequest(URL: NSURL(string: url)!)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            if data != nil {
                
                if let unwrappedData = data as NSData! {
                    completion(image: UIImage(data: unwrappedData))
                }
            }
        }.resume()
    }
}