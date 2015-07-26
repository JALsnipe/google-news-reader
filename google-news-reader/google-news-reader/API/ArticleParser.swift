//
//  ArticleParser.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

// This is my Article prototype object
// It is used to create a tempoary article object before saving an NSManagedObject to Core Data
struct ArticlePrototype {
    var title: String!
    var description: String!
    var imageURL: String!
    var image: UIImage?
    var date: NSDate!
    var articleURL: String!
}

class ArticleParser: NSObject {
    
    var parser: NSXMLParser!
    
    // These are class variables used by the parser
    // They hold information that will create an ArticleProtoptye object
    var element = ""
    var articles = [ArticlePrototype]()
    var articleTitle = ""
    var articleDescription = ""
    var articleImageURL = ""
    var articleDate = ""
    var articleURL = ""
    
    // This custom init allows us to initialize my parser class with data returned from the fetchAllArticlesWithCompletion network call
    convenience init (data: NSData) {
        self.init()
        
        self.parser = NSXMLParser(data: data)
        self.parser.delegate = self
    }
    
    // This method allows the NetworkManager class to inerface with the XML parser used by this parsing class, without accessing it directly
    // On sucessful parsing, it also invokes the image downloading method
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
    // These are methods used to help me with parsing HTML or any of the properties associated with an Article
    
    // This method strips the HTML tags (<>) from an input string
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
    
    // This method takes in an <img> tag and returns the URL of the image
    func getImageLinkFromImgTag(input:String) -> String {
        
        // First, get the entire <img> tag containing the image URL
        
        do {
            let regex = try NSRegularExpression(pattern: kImgTagRegEx, options: NSRegularExpressionOptions.CaseInsensitive)
            
            let results = regex.matchesInString(input, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, input.characters.count))
            
            if let match = results.first as NSTextCheckingResult! {
                // create temporary NSString to use NSRange for substringWithRange
                let str = input as NSString
                let imgTag = str.substringWithRange(match.range)
                
                // we have the image tag, now we need to extract the image URL
                
                do {
                    // find our url, it is encapsolated like "//[url]"
                    let imgRegex = try NSRegularExpression(pattern: kImgTagUrlRegEx, options: NSRegularExpressionOptions.CaseInsensitive)
                    
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
    
    // I use class variables to hold information about an Article
    // When the parser moves to the next item, I clear out the class variables so they may be used again
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        self.element = elementName
        
        if self.element == "item" {
            // next element, clear class variable property containers
            self.articleTitle = ""
            self.articleDescription = ""
            self.articleImageURL = ""
            self.articleDate = ""
            self.articleURL = ""
        }
    }
    // When the parser finds characters associated with an element I want to store, I capture the characters found in a class variable
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
    
    // Once an item has been completely parsed, I take the information stored in the class variables and construct an ArticlePrototype object with their content
    // I then add each ArticlePrototype object to an array to be returned by the class
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
