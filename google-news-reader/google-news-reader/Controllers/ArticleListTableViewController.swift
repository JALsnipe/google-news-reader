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
    
    var articleDataSource = [ArticlePrototype]()
    
    var context: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let articlesFetchRequest = NSFetchRequest(entityName: "Article")
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        articlesFetchRequest.sortDescriptors = [sortDescriptor]
        
        let frc = NSFetchedResultsController(fetchRequest: articlesFetchRequest, managedObjectContext: self.context, sectionNameKeyPath: nil, cacheName: nil)
        
        frc.delegate = self
        
        return frc
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            if let unwrappedData = data as? NSData {
                NetworkManager().parseAllArticleData(unwrappedData, completion: { (content, error) -> Void in
                    
                    if error == nil {
                        if let unwrappedContent = content as [ArticlePrototype]! {
                            self.articleDataSource = unwrappedContent
                            
                            // hop back on the main thread to reload, since we're in an async callback
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                                
                                do {
                                    try self.fetchedResultsController.performFetch()
                                    
                                    print("fetch")
                                    self.tableView.reloadData()
                                } catch {
                                    print("Error: \(error)")
                                }
                            })
                            
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

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if let sections = fetchedResultsController.sections {
//            let currentSection = sections[section] as NSFetchedResultsSectionInfo
//            return currentSection.numberOfObjects
//        }
        
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
        
        // TODO: FixMe, refresh article content rather than just table view
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
            sender.endRefreshing()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ArticleListTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: NSManagedObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        if let unwrappedIndexPath = indexPath as NSIndexPath!, unwrappedNewIndexPath = newIndexPath as NSIndexPath! {
            
            switch type {
            case NSFetchedResultsChangeType.Insert:
                self.tableView.insertRowsAtIndexPaths([unwrappedNewIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
            case NSFetchedResultsChangeType.Move:
                self.tableView.moveRowAtIndexPath(unwrappedNewIndexPath, toIndexPath: unwrappedNewIndexPath)
                
            case NSFetchedResultsChangeType.Delete:
                self.tableView.deleteRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                
            case NSFetchedResultsChangeType.Update:
                self.tableView.reloadRowsAtIndexPaths([unwrappedIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
}
