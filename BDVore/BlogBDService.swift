//
//  BlogService.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/12/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import Foundation
import UIKit

/*
 For now the class will be used to call NetworkOperation, retrieve the required data, and assign it to an array
 Once we have a more complex blog class (for now just [NSDictionary]), we will need to refine this method
 
 */
class BlogService{
    
    //TODO: Create something more generic to initialize BlogsAPIURL
    let blogsRSSURL: [NSURL?] = [
        NSURL(string: "http://bloglaurel.com/rss/fr"),
        NSURL(string: "http://vidberg.blog.lemonde.fr/feed/"),
        NSURL(string:"http://blog.chabd.com/abonnement.xml"),
        NSURL(string:"http://obion.fr/blog/feed/"),
        NSURL(string:"http://www.paka-blog.com/feed/"),
        NSURL(string:"http://www.juliemaroh.com/feed/"),
        NSURL(string:"http://www.bouletcorp.com/feed/"),
        NSURL(string:"http://yatuu.fr/feed/"),
        
        //NSURL(string:"http://www.lewistrondheim.com/blog/rss/fil_rss.xml"),
        //NSURL(string:"http://www.monsieur-le-chien.fr/rss.php"),
        //NSURL(string:"http://koudavbine.blogspot.com/feeds/posts/default"),

        ]
    
    
    /**
     Retrieve all the blogPosts in multiple websites
     TODO: SEND MULTIPLE COMPLETION, NEEDS TO BE FIXED
     */
    func getBlogs(completion: ([BlogPost]? -> Void)){
        
        var blogPosts = [BlogPost]()
        
        
        //TODO: remove force unwrapping
        for blogRSSURL in blogsRSSURL{
            var locked = true
            let networkOperation = NetworkOperation(url: blogRSSURL!)
            networkOperation.downloadXMLFromUrl{
                (let xmlIndexer) in
                if let posts = self.blogsFromRSS(xmlIndexer) {
                    blogPosts.appendContentsOf(posts)
                    }
                locked = false
                }
            while(locked){wait()}
        }
        completion(blogPosts)
        print("getBlogs function done")
        print("Number of blogs:\(blogPosts.count)")
    }
    


    func wait()
    {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 1))
    }
    
    
    
    /**
     Retrieve all blogPosts from a RSS feed (in an XMLIndexer format)
     */
    func blogsFromRSS(xmlIndexer: XMLIndexer?) -> [BlogPost]? {
        
        var locked = true
        
        
        if let entries = xmlIndexer?["rss"]["channel"]{
            var blogPosts = [BlogPost]()
            for item in entries["item"]{
                //a post is always supposed to have a title, a link and a date
                if let title = item["title"].element?.text,
                    let linkString = item["guid"].element?.text,
                    let dateString = item["pubDate"].element?.text,
                    let author = authorFromRSS(xmlIndexer){
                    
                    let date: NSDate = Date.parse(dateString, format: "EEE, dd MMM yyyy HH:mm:ss O")
                    let link: NSURL = NSURL(string: linkString)!
                    let thumbnail: UIImage = getThumbnailImage(author)
                    
                    blogPosts.append(BlogPost(title: title, author: author, date: date, link: link, thumbnail: thumbnail))
                    print("entry found")
                    locked = false
                } else{
                    print("Title, URL, Author or Date missing")
                    locked = false
                }
                while(locked){wait()}
            }
            return blogPosts
        } else {
            print("No entries found")
            return nil
        }
    }

    
    /**
    Sort a set of blogs, group them by date, and send back multiple organized set of blog Posts
    */
    func organizeBlogPosts(blogPosts: [BlogPost], periodDays: Int = 7) -> [[BlogPost]]{
        let today = NSDate()
        var organizedBlogPosts = [[BlogPost]]()
        
        for index in 0...periodDays-1 {
            //filter based on date
            var blogsInOneSection = blogPosts.filter({Date.sameDate($0.date, secondDate: today.dateByAddingTimeInterval(-Double(index)*24*60*60))})
            //var blogsInOneSection = blogPosts.filter({$0.date.isEqualToDate(today.dateByAddingTimeInterval(-Double(index)*24*60*60))})
            //sort by descending date order
            blogsInOneSection.sortInPlace({$0.date.compare($1.date) == .OrderedDescending})
            organizedBlogPosts.append(blogsInOneSection)
        }
        return organizedBlogPosts
    }
    
    //MARK: -Helper methods
    
    /**
    We retrive a thumbnail image from our library based on a set of predefined authors
     */
    func getThumbnailImage(author: String) -> UIImage{
        if let thumbnailImage = UIImage(named: author){
            return thumbnailImage
        } else {
            print("No pic found for:\(author)")
            return UIImage(named: "default")!
        }
    }

    /**
     Retrieve the title of the site post from a RSS feed (in an XMLIndexer format)
     */
    func authorFromRSS(xmlIndexer: XMLIndexer?) -> String? {
        //We are taking the very first entry of the RSS feed
        if let author = xmlIndexer?["rss"]["channel"]["title"][0].element?.text{
            return author
        }else{
            print("The RSS feed has no title / author")
            return nil
        }
    }
    
}
