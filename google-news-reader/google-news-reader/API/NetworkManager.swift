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
}
