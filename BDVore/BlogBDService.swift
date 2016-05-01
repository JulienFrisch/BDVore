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
     Retrieve all the blogPosts
     */
    func getBlogs(numberOfPosts: Int, completion: ([BlogPost]? -> Void)){
        //TODO: remove force unwrapping
        for blogRSSURL in blogsRSSURL{
            let networkOperation = NetworkOperation(url: blogRSSURL!)
            networkOperation.downloadXMLFromUrl{
                (let xmlIndexer) in
            
                //let blogs = self.blogsFromRSS(xmlIndexer)
                //completion(blogs)
            
                if let posts = self.latestPostFromRSS(3, xmlIndexer: xmlIndexer) {
                        completion(posts)
                    }

                }
        }
    }
    
    /**
     Retrieve a set of blogPosts from a RSS feed (in an XML format)
     */
    func blogsFromRSS(xmlIndexer: XMLIndexer?) -> [BlogPost]? {
        if let entries = xmlIndexer?["rss"]["channel"]{
            var blogPosts = [BlogPost]()
            for item in entries["item"]{
                //a post is always supposed to have a title, a link and a date
                if let title = item["title"].element?.text,
                    let linkString = item["guid"].element?.text,
                    let dateString = item["pubDate"].element?.text{
                    
                    let date: NSDate = Date.parse(dateString, format: "EEE, dd MMM yyyy HH:mm:ss O")
                    let link: NSURL = NSURL(string: linkString)!
                    
                    let blogPost = BlogPost(title: title, author: "Laurel", date: date, link: link, thumbnail: UIImage(named: "treehouse")!)
                    
                    blogPosts.append(blogPost)
                }
                
            }
            return blogPosts
        } else {
            print("JSON Dictionary returned nil for 'posts' key")
            return nil
        }
    }
    
    
    /**
     Retrieve the latest post from a RSS feed (in an XMLIndexer format)
     */
    func latestPostFromRSS(numberOfPosts: Int, xmlIndexer: XMLIndexer?) -> [BlogPost]? {
        var blogPosts = [BlogPost]()
        for index in 0...numberOfPosts-1{
            //We are taking the last three entries of the RSS feed
            if let item = xmlIndexer?["rss"]["channel"]["item"][index]{
                
                //a post is always supposed to have a title, a link and a date
                if let title = item["title"].element?.text,
                    let linkString = item["guid"].element?.text,
                    let dateString = item["pubDate"].element?.text,
                    let author = authorFromRSS(xmlIndexer){
                    
                    let date: NSDate = Date.parse(dateString, format: "EEE, dd MMM yyyy HH:mm:ss O")
                    let link: NSURL = NSURL(string: linkString)!
                    let thumbnail: UIImage = getThumbnailImage(author)
                    
                    blogPosts.append(BlogPost(title: title, author: author, date: date, link: link, thumbnail: thumbnail))
                    
                }else {
                    print("Title, URL or date missing")
                }
                
            }else {
                print("No entries found")
            }
        }
        return blogPosts
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
