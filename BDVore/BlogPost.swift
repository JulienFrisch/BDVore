//
//  BlogPosts.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/24/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import Foundation
import UIKit

//TODO: Check if need to inherits NSObject
class BlogPost{
    let title: String
    let author: String
    let date: NSDate
    let link: NSURL
    let thumbnail: UIImage
    
    init(title: String, author: String, date: NSDate, link: NSURL, thumbnail: UIImage){
        self.title = title
        self.author = author
        self.date = date
        self.link = link
        self.thumbnail = thumbnail
    }
}