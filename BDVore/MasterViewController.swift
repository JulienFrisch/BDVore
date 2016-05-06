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
    var organizedBlogPosts = [[BlogPost]]()
    //make sure you always enter ordered dates
    let section = ["Aujourd'hui",
                   "Hier",
                   "Il y a deux jours",
                   "Il y a trois jours",
                   "Il y a quatre jours",
                   "Il y a cinq jours",
                   "Il y a six jours"]

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveBlogs()
        self.refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /**
     We use this function to refresh the data. It is triggered when the tableview is pulled
    */
    func handleRefresh(refreshControl: UIRefreshControl) {
        retrieveBlogs()
        refreshControl.endRefreshing()
    }
    
    //We use this function to load all blogs in blogPosts and reload the table view
    func retrieveBlogs(){
        //set a lock during your async function
        var locked = true
        
        let blogService = BlogService()
        var unsortedBlogPosts = [BlogPost]()
        blogService.getBlogs{
            //closure with stored variable of type [NSDictionary]
            (let blogPosts) in
            //we unwrap blogs
            if let blogPosts = blogPosts{
                for post in blogPosts {
                    unsortedBlogPosts.append(post)
                }
            }
        locked = false
        }
        while(locked){Delay.wait()}
        //Warning: We are still on background thread. When updating UI, we need to be on the main thread. We use GDC API for that
        dispatch_async(dispatch_get_main_queue()){
            self.organizedBlogPosts=blogService.organizeBlogPosts(unsortedBlogPosts, periodDays: self.section.count)
            self.tableView.reloadData()
        }
    }
    

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showBlogPost" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! WebViewController
                
                //pass blog
                controller.blogPost = self.organizedBlogPosts[indexPath.section][indexPath.row]
                
                //TODO: check what the rest if used for
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
           }
        }
    }

    // MARK: - Table View


    /**
     Return Number of sections in the table
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.section.count
    }

    /**
    Return Number of entries in a section
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //we check if organizedBlogPosts has already been initialized
        if self.organizedBlogPosts.count == 0 {
            //not initialized => we do not display anything
            return 0
        } else {
            return self.organizedBlogPosts[section].count
        }
        //return self.blogPosts.count
    }
 
    /**
    Fill table view cells
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //we use dequeueReusable to avoid loading too much data in case we have a long array
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        //we retrieve the proper blogpost
        //let blogPost: BlogPost = self.blogPosts[indexPath.row]
        let blogPost : BlogPost = self.organizedBlogPosts[indexPath.section][indexPath.row]
        
        //we assign the title label to the cell as subtitle
        cell.textLabel?.text = blogPost.title
        //we assign the author label and the date to the cell as subtitle
        cell.detailTextLabel?.text="\(blogPost.author) - \(Date.getStringFromDate(blogPost.date))"
        //we assign the post image to the cell
        cell.imageView?.image = blogPost.thumbnail
        //cell.imageView?.image = blogPost.thumbNail
        
        return cell
    }
    
    /**
    Name the section headers
    */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.section[section]
        
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

