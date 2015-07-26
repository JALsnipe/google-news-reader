//
//  ArticleDetailTableViewController.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/26/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailTableViewController: UITableViewController {
    
    var article: Article?
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up row height
        self.tableView.estimatedRowHeight = 88.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // Estimate the height of our WKWebView footer
        // Should be: height of table view - height of header cell (only cell) - navigation bar height - status bar height
        let webViewHeight = self.tableView.frame.size.height - self.tableView.estimatedRowHeight - (self.navigationController?.navigationBar.frame.size.height)! - UIApplication.sharedApplication().statusBarFrame.height
        
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: webViewHeight))
        webView.loadRequest(NSURLRequest(URL: NSURL(string: (self.article?.articleURL)!)!))
        
        // Set the delegate to self so we get loading success and failure callbacks
        // Delegate methods implemented below in the extension
        webView.navigationDelegate = self
        
        self.tableView.tableFooterView = webView
        
        // Set up activity indicator for web view loading
        self.spinner.center = self.view.center
        self.spinner.color = UIColor.purpleColor()
        self.view.addSubview(self.spinner)
        self.view.bringSubviewToFront(self.spinner)
        self.spinner.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleHeader", forIndexPath: indexPath) as! ArticleHeaderTableViewCell

        cell.articleTitleLabel.text = self.article?.title
        
        if let imageObj = self.article?.image {
            if let image: UIImage = imageObj as? UIImage {
                cell.articleImageView.image = image
            }
        }

        return cell
    }

}

// MARK: WKNavigationDelegate methods

extension ArticleDetailTableViewController: WKNavigationDelegate {
    
    // When initial navigation finishes, stop our spinner
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        // stop spinner
        spinner.stopAnimating()
        spinner.hidden = true
    }
    
    // If the request fails with an error, alert the user
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error)
        
        var userMessage: String?
        
        switch error.code {
        case NSURLErrorNotConnectedToInternet:
            userMessage = NetworkError.NetworkFailure.localizedDescription
        
        default:
            userMessage = NetworkError.UnknownError.localizedDescription
        }
        
        self.alertUserWithTitleAndMessage("Error", message: userMessage)
    }
}
