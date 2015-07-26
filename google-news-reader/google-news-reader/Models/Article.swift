//
//  Article.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/26/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Article: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    
    convenience init(prototype: ArticlePrototype) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: appDelegate.managedObjectContext)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: appDelegate.managedObjectContext)
        
        self.title = prototype.title
        
        self.articleDesciption = prototype.description
        
        self.imageURL = prototype.imageURL
        self.date = prototype.date
        self.articleURL = prototype.articleURL
        
        if let image = prototype.image as UIImage! {
            self.image = image
        }
    }

}
