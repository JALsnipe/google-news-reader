//
//  Constants.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

let kGoogleNewsRSSURL = "http://news.google.com/?output=rss"

let kHTTPResponseStatusCodeSuccess = 200

let kGoogleNewsArticleDateFormat = "EEE, d MMM yyyy HH:mm:ss Z"

// Regular Expressions
let kImgTagRegEx = "<img src=[^>]+>"
let kImgTagUrlRegEx = "\"//(.*?)\""

// Error Messages
let kNetworkFailureMessage = "There was a problem downloading articles. Please check your network connetion and try again"
let kParsingErrorMessage = "The was a problem parsing downloaded articles. Please try again."
let kUnknownErrorMessage = "There was a problem downloading articles. Please try again later."