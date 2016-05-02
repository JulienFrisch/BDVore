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
    
    class func sameDate(firstDate: NSDate, secondDate: NSDate) -> Bool{
        let calendar = NSCalendar.currentCalendar()
        
        let componentsFirstDate = calendar.components([.Day , .Month , .Year], fromDate: firstDate)
        let year1 =  componentsFirstDate.year
        let month1 = componentsFirstDate.month
        let day1 = componentsFirstDate.day
        
        let componentsSecondDate = calendar.components([.Day , .Month , .Year], fromDate: secondDate)
        let year2 =  componentsSecondDate.year
        let month2 = componentsSecondDate.month
        let day2 = componentsSecondDate.day
        
        if day1 == day2 && month1 == month2 && year1 == year2{
            return true
        } else {
            return false
        }
    }
    
}