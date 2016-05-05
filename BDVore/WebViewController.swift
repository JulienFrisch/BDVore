//
//  DetailViewController.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/11/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var blogPostURL: NSURL?

    
    //TODO: What to do with this? Kind of replaced with blogPostURL
    /*var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.description
            }
        }
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.configureView()
        
        //we want the web page to be scaled and we want to allow zoom in and zoom out
        webView.scalesPageToFit = true
        
        //to be updated
        if let url = blogPostURL{
            let urlRequest: NSURLRequest = NSURLRequest(URL: url)
            self.webView.loadRequest(urlRequest)
        } else {
            print("No URL found")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

