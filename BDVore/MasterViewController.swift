//
//  MasterViewController.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/11/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var webViewController: WebViewController? = nil
    var objects = [AnyObject]()
    var blogPosts: [BlogPost] = [BlogPost]()

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveBlogs()
    }
    
    //We use this function to load all blogs in blogPosts and reload the table view
    func retrieveBlogs(){
        let blogService = BlogService()
        blogService.getBlogs{
            //closure with stored variable of type [NSDictionary]
            (let blogPosts) in
            //we unwrap blogs
            if let blogPosts = blogPosts{
                for post in blogPosts {
                    self.blogPosts.append(post)
                }
            }
            //Warning: We are still on background thread. When updating UI, we need to be on the main thread. We use GDC API for that
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.reloadData()
                print("reload data done")
            }
        }
        
        /* DELETED FOR NOW
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
         */

    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /* DELETED FOR NOW
    func insertNewObject(sender: AnyObject) {
        objects.insert(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
     */

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBlogPost" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WebViewController
                
                //pass URL
                let link = blogPosts[indexPath.row].link
                controller.blogPostURL = link
                
                //TODO: check what the rest if used for
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
           }
        }
    }

    // MARK: - Table View
    //TODO: Organize sections by dates

    //Return the number of sections in the tableau.
    //In this example, no sections, so one by default
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    //Number of titles in our array
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blogPosts.count
    }
 
    //return a table view cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //we use dequeueReusable to avoid loading too much data in case we have a long array
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        //we retrieve the proper blogpost
        let blogPost: BlogPost = self.blogPosts[indexPath.row]
        
        //we assign the title label to the cell as subtitle
        cell.textLabel?.text = blogPost.title
        //we assign the author label and the date to the cell as subtitle
        cell.detailTextLabel?.text="\(blogPost.author) - \(Date.getStringFromDate(blogPost.date))"
        //we assign the post image to the cell
        cell.imageView?.image = blogPost.thumbnail
        //cell.imageView?.image = blogPost.thumbNail
        
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    //MARK: -Helper methods
    
//    func assignBlogPosts(blogs: [NSDictionary]) -> [NSDictionary] {
//        for entry in blogs {
//            let blog = ["title",entry.va]
//        }
//    }

    /*DELETED FOR NOW
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    */


}

