//
//  ViewController.swift
//  google-news-reader
//
//  Created by Josh L on 7/24/15.
//  Copyright © 2015 Lieberman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NetworkManager().fetchAllArticlesWithCompletion { (data, error) -> Void in
            if let unwrappedData = data as? NSData {
                NetworkManager().parseAllArticleData(unwrappedData)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

