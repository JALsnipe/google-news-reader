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
    var imageURL: String!
    var image: UIImage?
    var date: NSDate!
    var articleURL: String!
}

class ArticleParser: NSObject {
    
    var data: NSData!
    var parser: NSXMLParser!
    
    var element = ""
    var articles = [ArticlePrototype]()
    var articleTitle = ""
    var articleDescription = ""
    var articleImageURL = ""
    var articleDate = ""
    var articleURL = ""
    
    convenience init (data: NSData) {
        self.init()
        
        self.data = data
        self.parser = NSXMLParser(data: data)
        self.parser.delegate = self
    }
    
    func parseDataWithCompletion(completion: (success: Bool) -> Void) {
        
        if self.parser.parse() {
            // parsing sucessful, now download images
            
            NetworkManager().downloadImagesForArticles(self.articles, completion: { (articlesWithImages) -> Void in
                self.articles = articlesWithImages
                completion(success: true)
            })
        } else {
            // there was an error parsing
            completion(success: false)
        }
        
    }
    
    // MARK: Parsing Helper Methods
    
    // Strips the HTML tags (<>) from an input string
    func stringByStrippingHTML(input: String) -> String {
        
        let stringlength = input.characters.count
        var newString = ""
        
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive)
            
            newString = regex.stringByReplacingMatchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, stringlength), withTemplate: "")
            
        } catch {
            print("Error stripping HTML from input string: \(error)")
        }
        
        return newString
    }
    
    // Takes in an <img> tag and returns the URL of the image
    func getImageLinkFromImgTag(input:String) -> String {
        
        // First, get the entire <img> tag containing the image URL
        
        do {
            let regex = try NSRegularExpression(pattern: "<img src=[^>]+>", options: NSRegularExpressionOptions.CaseInsensitive)
            
            let results = regex.matchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, input.characters.count))
            
            if let match = results.first as NSTextCheckingResult! {
                // create temporary NSString to use NSRange for substringWithRange
                let str = input as NSString
                let imgTag = str.substringWithRange(match.range)
                
                // we have the image tag, now we need to extract the image URL
                
                do {
                    // find our url, it is encapsolated like "//[url]"
                    let imgRegex = try NSRegularExpression(pattern: "\"//(.*?)\"", options: NSRegularExpressionOptions.CaseInsensitive)
                    
                    let imgResults = imgRegex.matchesInString(imgTag, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, imgTag.characters.count))
                    
                    if let imgMatch = imgResults.first as NSTextCheckingResult! {
                        // create temporary NSString to use NSRange for substringWithRange
                        let tagStr = imgTag as NSString
                        let imgURL = "http:" + tagStr.substringWithRange(imgMatch.range).stringByReplacingOccurrencesOfString("\"", withString: "")
                        
                        return imgURL
                    }
                    
                } catch {
                    print("Error parsing URL from <img> tag: \(error)")
                }
            }
        } catch {
            print("Error parsing <img> tag: \(error)")
        }
        
        return ""
    }
    
    // Takes in a Article date string and returns an NSDate object
    // If the date cannot be parsed, returns the current date
    func dateFromString(input: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = kGoogleNewsArticleDateFormat
        
        if let date = dateFormatter.dateFromString(input) {
            return date
        }
        
        return NSDate()
    }
}

// MARK: NSXMLParserDelegate Methods

extension ArticleParser: NSXMLParserDelegate {
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.element = elementName
        
        if self.element == "item" {
            // next element, clear class property containers
            self.articleTitle = ""
            self.articleDescription = ""
            self.articleImageURL = ""
            self.articleDate = ""
            self.articleURL = ""
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        switch self.element {
        case "title":
            self.articleTitle += string
            
        case "description":
            self.articleDescription += string
            
        case "link":
            self.articleURL += string
        
        case "pubDate":
            self.articleDate += string
        
        default:
            break
        }
        
        // image link is in description HTML string
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "item" {
            if !self.articleTitle.isEmpty && !self.articleDescription.isEmpty {
                
                // article prototype constructor
                let article = ArticlePrototype(title: self.articleTitle, description: self.stringByStrippingHTML(self.articleDescription), imageURL: self.getImageLinkFromImgTag(self.articleDescription), image: nil, date: self.dateFromString(self.articleDate), articleURL: self.articleURL)
                
                self.articles.append(article)
            }
        }
    }
}
