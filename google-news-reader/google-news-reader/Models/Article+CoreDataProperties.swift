//
//  Article+CoreDataProperties.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/26/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Article {

    @NSManaged var title: String?
    @NSManaged var articleDesciption: String?
    @NSManaged var imageURL: String?
    @NSManaged var image: NSObject?
    @NSManaged var date: NSObject?
    @NSManaged var articleURL: String?

}
