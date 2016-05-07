//
//  NetworkOperation.swift
//  BlogReader
//
//  Created by Julien Frisch on 4/11/16.
//  Copyright © 2016 Julien Frisch. All rights reserved.
//

import Foundation
import SystemConfiguration

class NetworkOperation{
    
    //we use lazy properties so it is not being loaded until it is actually used
    lazy var config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.config) //need to add self since we are using lazy property
    let queryURL: NSURL
    
    //review completion courses
    typealias XMLDictionaryCompletion = (XMLIndexer?) -> Void
    
    init(url: NSURL){
        queryURL = url
    }
    
    /**
     Download a XMLIndexer from the stored property queryURL
     */
    func downloadXMLFromUrl(completion: XMLDictionaryCompletion){
        let request: NSURLRequest = NSURLRequest(URL: queryURL)
        let dataTask = session.dataTaskWithRequest(request){
            //when closure is the last parameter of a function, it can be written as a trailing closure instead
            (let data, let response, let error) in
            //1. Check HTTP response for succesful GET request
            if let httpResponse = response as? NSHTTPURLResponse {
                switch(httpResponse.statusCode) {
                case 200:
                    //2. create XML object with data
                    let xmlIndexer = SWXMLHash.parse(data!)
                    completion(xmlIndexer)
                    
                default: print("Get Request not succesful, HTTP status code: \(httpResponse.statusCode))")
                    completion(nil)
                }
                
            } else {
                print("Error, not a valid URL response")
                completion(nil)
            }
        }
        dataTask.resume()
    }
    
    /**
     Check if connected to network
    */
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
}






    