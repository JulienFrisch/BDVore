//
//  MasterViewController.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/11/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    //contain the blogs display in the table
    var organizedBlogPosts = [[BlogPost]]()
    
    //make sure you always enter ordered dates
    //sections will later be refined depending on whether or not each section has at least one blogPost
    var sections = ["Aujourd'hui",
                   "Hier",
                   "Il y a deux jours",
                   "Il y a trois jours",
                   "Il y a quatre jours",
                   "Il y a cinq jours",
                   "Il y a six jours"]
    
    //label used when no blogPosts available, managed programmatically
    var noBlogsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //we initiate the no blogs label but do not display it
        initiateNoBlogsLabel()
        
        //retrieve blogs in organizedBlogPosts and display tableview
        retrieveBlogs()
        
        //add a refresh button
        self.refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    /**
     We use this function to refresh the data. It is triggered when the tableview is pulled
    */
    func handleRefresh(refreshControl: UIRefreshControl) {
        
        retrieveBlogs()
        
        //we ask the refresh wheel (refreshControl) to stop turning
        refreshControl.endRefreshing()
        
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
        return self.sections.count
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
    Needs to be called once sections have been refined to remove empty sections
    */
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    //MARK: -Helper methods
    
    /**
    We use this function to load all blogs in blogPosts and reload the table view
    */
    func retrieveBlogs(){
        //set a lock during your async function
        var locked = true
        
        let blogService = BlogService()
        var unsortedBlogPosts = [BlogPost]()
        blogService.getBlogs{
            //closure with stored variable of type [BlogPost]
            (let blogPosts) in
            //we unwrap blogs
            if let blogPosts = blogPosts{
                unsortedBlogPosts.appendContentsOf(blogPosts)
            }
            locked = false
        }
        //we wait for the getBlogs closure to finish before moving on
        while(locked){Delay.wait()}
        //Warning: We are still on background thread. When updating UI, we need to be on the main thread. We use GDC API for that
        dispatch_async(dispatch_get_main_queue()){
            (self.organizedBlogPosts,self.sections)=blogService.organizeBlogPosts(unsortedBlogPosts, sections: self.sections)
            
            //we update the table view
            self.tableView.reloadData()
            
            //check if no blogPosts
            if self.organizedBlogPosts.count == 0 {
                //display a "no blogs" message
                self.displayNoBlogsLabel()
            } else {
                self.hideNoBlogsLabel()
            }
        }
    }
    
    /**
    Create the no blogs label, but does not display it
    */
    func initiateNoBlogsLabel(){
        //Initialize noBlogsLabel: position & Text Alignment

        //Position
        let frame: CGRect = UIScreen.mainScreen().bounds //get screen frame size
        self.noBlogsLabel = UILabel(frame:  CGRectMake(0, 0, frame.size.width, frame.size.height))
        
        //text alignment
        self.noBlogsLabel.textAlignment = NSTextAlignment.Center
        
        //Initialize noBlogsLabel: text
        self.noBlogsLabel.text = "Pas de nouveaux posts cette semaine! :("
    }
    
    /**
     Display the no blogs information message
    */
    func displayNoBlogsLabel(){
        print("display no blogs")
        
        //add it to the view
        self.view.addSubview(self.noBlogsLabel)
    }
    
    /**
    Hide the no blog information message
    */
    func hideNoBlogsLabel(){
        self.noBlogsLabel.removeFromSuperview()
    }


}

