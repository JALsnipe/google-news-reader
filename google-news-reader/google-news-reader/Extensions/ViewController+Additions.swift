//
//  ViewController+Additions.swift
//  google-news-reader
//
//  Created by Josh Lieberman on 7/26/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Takes in title and message strings and presents a UIAletController
    func alertUserWithTitleAndMessage(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
