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
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        articlesFetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: articlesFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return frc
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // perform an intial fetch to show cached data
        do {
            try self.fetchedResultsController.performFetch()
            
            self.tableView.reloadData()
        } catch {
            print("Error performing initial fetch: \(error)")
        }
        
        // Download new articles
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            
            if error != nil {
                // TODO: handle errors and return
            }
            
            if let unwrappedData = data as? NSData {
                NetworkManager().parseAllArticleData(unwrappedData, completion: { (content, error) -> Void in
                    
                    if error == nil {
                        // hop back on the main thread to reload, since we're in an async callback
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
                        // TODO: handle error
                    }
                    
                })
            }
        }
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
        
        if let results = self.fetchedResultsController.fetchedObjects?.count {
            return results
        }
        
        return 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // TODO: FIXME, custom cells
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
            cell.textLabel?.text = dataSource[indexPath.row].title
            cell.detailTextLabel?.text = dataSource[indexPath.row].description
            
            if let cellImage: UIImage = dataSource[indexPath.row].image as? UIImage {
                cell.imageView?.image = cellImage
            }
        }
        
        
        

        return cell
    }
    
    @IBAction func refreshTable(sender: AnyObject) {
        
        // TODO: FIXME, refresh article content rather than just table view
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }
    
}
