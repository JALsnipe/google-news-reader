# google-news-reader
Google News RSS Reader in Swift 2.0

![simulator screen shot jul 26 2015 11 56 51 pm](https://cloud.githubusercontent.com/assets/4513736/8898443/44e7be9e-33f2-11e5-90b5-310dd6b10008.png)
![simulator screen shot jul 26 2015 11 57 01 pm](https://cloud.githubusercontent.com/assets/4513736/8898444/460ae076-33f2-11e5-8a98-f28fb2c2d036.png)


Development Environment: Xcode 7 Beta 4

Test devices: iPhone 5 running iOS 8.1 and iPhone 6 running iOS 8.4. iPhone Simulator (all devices) running iOS 9 Beta

###Requirements:
* Article List View
 * The app opens to a table view, which downloads and displays a list of articles.  Each cell in the table contains the article title, a description, and an image where applicable.  A placeholder image is used if one is not found or returned from the network call.
* Article Detail View
 * If the user taps a cell, they are brought to an article detail view containing the title of the article, an image (or placeholder) and the full article content.
* Testing
 * Functional and API tests are included in `google_news_readerTests.swift`.  All current test cases pass.
* Dependencies
 * I do not use any outside libraries or frameworks.  Just build and run the project from the `xcodeproj` file.
* Caching
 * The app caches article data in Core Data.  Data is loaded from Core Data into the initial article list table view using an `NSFetchedResultsController`.  If the app is launched without Internet, but has previously downloaded articles successfully, those articles will persist.  The article content (webpage) is not cached.

###Project Architecture:
I broke the project into three main buckets of complexity: API (network requests and data parsing), Data Models, and View Controllers.
* The API group contains a Network Manager, which performs web requests to get article data.  It contains a custom `ErrorType` that is used app-wide to handle any issues that may come from network or data parsing errors.  The Network Manager hooks directly into my XML parsing abstraction class, `ArticleParser`.  This class provides a wrapper around the built-in `NSXMLParser`, taking in article `NSData`, parsing through it item by item, creating prototype Article objects.
* The Models group contains my Article `NSManagedObject`, custom initilizers, and a Core Data helper class to cache the prototype Article objects returned from the parser into Core Data as `NSManagedObjects`.
* The Controllers group contains the master and detail `UIViewController` subclasses and their associated custom `UITableViewCells`.

###Supporting Files:
* My app contains a Constants file, which contains some commonly used constant values: the RSS URL, the data formatter string for article publication dates, regular expressions used, status codes, and client-facing error Strings.
* My app also contains an extension allowing any `UIViewController` to present a `UIAlertController` with a specified title and message.

###Google News Feed:
* This was my first time using `NSXMLParser`, as I am more accustomed to using JSON with REST APIs.  I had hoped a REST API for Google News with JSON data would be available for me to use for this application.  One exists, but is [deprecated](https://developers.google.com/news-search/v1/jsondevguide).  Although the REST endpoints may still function, I did not want to risk integrating my application with a deprecated API.
* I found it difficult to parse the HTML returned as part of an object description.  The RSS feed returns an entire HTML table as the description, rather than just a plaintext string.  I ultimately wrote some regular expressions to parse the HTML as best I could (and get the image out of the HTML), but the article description is not fully HTML escaped.  You can see more in [PR #5](https://github.com/JALsnipe/google-news-reader/pull/5)
* Google aggregates news from hundreds, if not thousands, of news sites.  It would be impossible to read the DOM of each site or utilize an API to get article content.  I ultimately solved this issue by displaying the selected article in a `WKWebView` in the article detail view.

###Next Steps:
There are a few things I would have liked to work on that I did not get to.
* I definitely want to explore UI Testing and write UI tests for this application.  The new UI testing APIs announced at WWDC this year will be core to testing and maintaining stable apps in the future.
* I would love fix the issue with article descriptions mentioned above.  I did not want to introduce any third-party dependencies into this project for HTML parsing, but I hope to explore stable options for parsing the data returned from the feed easier.
* The UI is straightforward, but bare bones.  I'd like to put more time into the presentation of the initial article list view.  Additionally, I’d like to look into creating prototype data that appears when the app first launches, so the initial state of the article list table view is not empty.

Although this project was built over the course of a weekend, I was able to touch a variety of different technologies and ultimately provide a solution to the problem presented to me.  I have utilized GitHub's Issue tracker and pull requests into the Development branch as a way to track and present my project.  Feel free to view each pull request, as I made comments about my findings, client-side implementation, testing, and design.

