//
//  CoreDataManager.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/26/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {

    func cacheFetchedArticles(articles: [ArticlePrototype]) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        var managedArray = [Article]()
        
        for articleProto in articles {
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
    }
}
