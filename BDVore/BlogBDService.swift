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
    let blogRSSURL = NSURL(string: "http://bloglaurel.com/rss/fr")
    
    
    /**
     Retrieve all the blogPosts
     */
    func getBlogs(completion: ([BlogPost]? -> Void)){
        //TODO: remove force unwrapping
        let networkOperation = NetworkOperation(url: blogRSSURL!)
        networkOperation.downloadXMLFromUrl{
            (let xmlIndexer) in
            
            //let blogs = self.blogsFromRSS(xmlIndexer)
            //completion(blogs)
            
            if let post = self.latestPostFromRSS(xmlIndexer) {
                let blogs = [post]
                completion(blogs)
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
     Retrieve the latest post from a RSS feed (in an XML format)
     */
    func latestPostFromRSS(xmlIndexer: XMLIndexer?) -> BlogPost? {
        //a post is always supposed to have a title, a link and a date
        if let item = xmlIndexer?["rss"]["channel"][0],
            let title = item["title"].element?.text,
            let linkString = item["guid"].element?.text,
            let dateString = item["pubDate"].element?.text{
            
                let date: NSDate = Date.parse(dateString, format: "EEE, dd MMM yyyy HH:mm:ss O")
                let link: NSURL = NSURL(string: linkString)!
                    
                return BlogPost(title: title, author: "Laurel", date: date, link: link, thumbnail: UIImage(named: "treehouse")!)
            } else {
            print("No proper entry found")
            return nil
        }
    }
    
    
    //a post may not always have an image, hence thumbnailString might be nil
    func getThumbnailImage(thumbnailString: String?) -> UIImage{
        if let thumbnailString = thumbnailString,
        let thumbnailURL = NSURL(string: thumbnailString),
        let thumbnailImageData: NSData = NSData(contentsOfURL: thumbnailURL),
            let thumbnailImage: UIImage = UIImage(data: thumbnailImageData){
            return thumbnailImage
        }else{
            print("No image found")
            //TODO: Choose another default picture
            return UIImage(named: "treehouse")!
        }
        
    }
    
}
