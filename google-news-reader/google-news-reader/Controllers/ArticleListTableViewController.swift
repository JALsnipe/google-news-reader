//
//  ArticleListTableViewController.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/25/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit
import CoreData

class ArticleListTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext!
    
    // Set up an NSFetchedResultsController to fetch articles by date published
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let articlesFetchRequest = NSFetchRequest(entityName: "Article")
        articlesFetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let frc = NSFetchedResultsController(fetchRequest: articlesFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform an intial fetch of Article objects from Core Data to show cached data, if any
        do {
            try self.fetchedResultsController.performFetch()
            
            self.tableView.reloadData()
        } catch {
            print("Error performing initial fetch: \(error)")
        }
        
        self.reloadTableWithArticles()
    }
    
    func reloadTableWithArticles() {
        // Download new articles
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            
            if error != nil {
                // handle errors and return
                if let networkError = error as? NetworkError {
                    switch networkError{
                    case .NetworkFailure:
                        self.alertUserWithTitleAndMessage("Network Error", message: kNetworkFailureMessage)
                        return
                        
                    default:
                        self.alertUserWithTitleAndMessage("Unknown Error", message: kUnknownErrorMessage)
                        return
                    }
                }
            }
            
            if let unwrappedData = data as? NSData {
                NetworkManager().parseAllArticleData(unwrappedData, completion: { (content, error) -> Void in
                    
                    if error == nil {
                        // Hop back on the main thread to reload, since we're in an async callback
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            do {
                                try self.fetchedResultsController.performFetch()
                                
                                self.tableView.reloadData()
                            } catch {
                                print("Error: \(error)")
                                // TODO: Core Data fetch failed, use prototype objects (content) returned
                            }
                        })
                    } else {
                        // handle error
                        if let networkError = error as? NetworkError {
                            switch networkError {
                            case .ParsingError:
                                self.alertUserWithTitleAndMessage("Network Error", message: kParsingErrorMessage)
                                return
                                
                            default:
                                self.alertUserWithTitleAndMessage("Unknown Error", message: kUnknownErrorMessage)
                            }
                        }
                    }
                    
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshTable(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.reloadTableWithArticles()
            sender.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let results = self.fetchedResultsController.fetchedObjects?.count {
            return results
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("articleListCell", forIndexPath: indexPath) as! ArticleListTableViewCell
        
        if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
            cell.articleTitleLabel.text = dataSource[indexPath.row].title
            cell.articleDescriptionLabel.text = dataSource[indexPath.row].articleDesciption
            
            if let cellImage: UIImage = dataSource[indexPath.row].image as? UIImage {
                cell.articleImageView.image = cellImage
            } else {
                cell.articleImageView.image = UIImage(named: "img_thumb_placeholder")
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showArticleDetail", sender: indexPath)
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Check if the destination view controller is the detail controller
        if let detailVC = segue.destinationViewController as? ArticleDetailTableViewController {
            // The sender should only be an indexPath, so unwrap it
            if let indexPath = sender as? NSIndexPath {
                // Find the Article from the indexPath.row specified and pass it to our destination view controller
                if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
                    detailVC.article = dataSource[indexPath.row]
                }
                
            }
        }
    }
}
