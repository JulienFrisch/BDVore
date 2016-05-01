//
//  Date.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/25/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import Foundation

class Date{
    
    class func parse(dateStr:String, format:String="yyyy-MM-dd") -> NSDate {
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        return dateFmt.dateFromString(dateStr)!
    }
    
    //helper class to get the date as a nice String with a predefined format (hardcoded)
    class func getStringFromDate(date: NSDate) -> String{
        let format = "EE dd MMM HH:mm"
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = format
        dateFmt.locale = NSLocale(localeIdentifier: "fr_FR")
        return dateFmt.stringFromDate(date)
    }
    
}