//
//  Wait.swift
//  BDVore
//
//  Created by Julien Frisch on 5/6/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import Foundation

class Delay{

    /**
    We use this function to wait for one second
    */
    class func wait()
    {
        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 1))
    }
}