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
        NSURL(string:"http://www.bouletcorp.com/feed/"),
        NSURL(string: "http://vidberg.blog.lemonde.fr/feed/"),
        NSURL(string:"http://blog.chabd.com/abonnement.xml")]
    
    
    /**
     Retrieve all the blogPosts in multiple websites
     */
    func getBlogs(completion: ([BlogPost]? -> Void)){
        //TODO: remove force unwrapping
        for blogRSSURL in blogsRSSURL{
            let networkOperation = NetworkOperation(url: blogRSSURL!)
            networkOperation.downloadXMLFromUrl{
                (let xmlIndexer) in
            
                //let blogs = self.blogsFromRSS(xmlIndexer)
                //completion(blogs)
            
                if let posts = self.blogsFromRSS(xmlIndexer) {
                        completion(posts)
                    }

                }
        }
    }
    
    /**
     Retrieve all blogPosts from a RSS feed (in an XMLIndexer format)
     */
    func blogsFromRSS(xmlIndexer: XMLIndexer?) -> [BlogPost]? {
        if let entries = xmlIndexer?["rss"]["channel"]{
            var blogPosts = [BlogPost]()
            for item in entries["item"]{
                //a post is always supposed to have a title, a link and a date
                if let title = item["title"].element?.text,
                    let linkString = item["guid"].element?.text,
                    let dateString = item["pubDate"].element?.text,
                    let author = authorFromRSS(xmlIndexer){
                    
                    print("Link:\(linkString)")
                    let date: NSDate = Date.parse(dateString, format: "EEE, dd MMM yyyy HH:mm:ss O")
                    let link: NSURL = NSURL(string: linkString)!
                    let thumbnail: UIImage = getThumbnailImage(author)
                    
                    blogPosts.append(BlogPost(title: title, author: author, date: date, link: link, thumbnail: thumbnail))
                } else{
                    print("Title, URL, Author or Date missing")
                }
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
        print("today:\(Date.getStringFromDate(today))")
        let yesterday = today.dateByAddingTimeInterval(-1*24*60*60)
        print("Yesterday:\(Date.getStringFromDate(yesterday))")
        for index in 0...periodDays-1 {
            //filter based on date
            var blogsInOneSection = blogPosts.filter({Date.sameDate($0.date, secondDate: today.dateByAddingTimeInterval(-Double(index)*24*60*60))})
            //var blogsInOneSection = blogPosts.filter({$0.date.isEqualToDate(today.dateByAddingTimeInterval(-Double(index)*24*60*60))})
            print("number of blogs in section\(index): \(blogsInOneSection.count)")
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
            //TODO: choose another default image
            return UIImage(named: "treehouse")!
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
