//
//  APIController.swift
//  NewUIYoumitter
//
//  Created by HOME on 28/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveAPIResults(results: NSDictionary)
}

class APIController {
    
    var delegate: APIControllerProtocol
    
    init(delegate: APIControllerProtocol) {
        self.delegate = delegate
    }
    
    var apiKey: String = ""
    var name: String = ""
    var userName: String = ""
    var imageUrl: String = ""
    var transType: String = ""
    var shareMedia: String = ""
    var defaultUserName: String = ""
    
    var userConstellations: NSMutableArray = NSMutableArray()
    var userConstellationIds: NSMutableArray = NSMutableArray()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    func loadUserDefaultsData() {
        //        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        if let apiKeyIsNotNill = defaults.objectForKey("apiKey") as? String {
            self.apiKey = defaults.objectForKey("apiKey") as String
        }
        
        
        if let userNameIsNotNill = defaults.objectForKey("userName") as? String {
            self.userName = defaults.objectForKey("userName") as String
        }
        
        if let defaultUserNameIsNotNill = defaults.objectForKey("defaultUserName") as? String {
            self.defaultUserName = defaults.objectForKey("defaultUserName") as String
        }
        
        if let nameIsNotNill = defaults.objectForKey("name") as? String {
            self.name = defaults.objectForKey("name") as String
        }
        
        if let transTypeIsNotNill = defaults.objectForKey("transType") as? String {
            self.transType = defaults.objectForKey("transType") as String
        }
        
        if let shareMediaIsNotNill = defaults.objectForKey("shareMedia") as? String {
            self.shareMedia = defaults.objectForKey("shareMedia") as String
        }
        
        if let imageUrlIsNotNill = defaults.objectForKey("imageUrl") as? String {
            self.imageUrl = defaults.objectForKey("imageUrl") as String
        }
        
        if let userConstellationsNotNill = defaults.objectForKey("userConstellations") as? NSMutableArray {
            self.userConstellations = defaults.objectForKey("userConstellations") as NSMutableArray
        }
        
        if let userConstellationIdsNotNill = defaults.objectForKey("userConstellationIds") as? NSMutableArray {
            self.userConstellationIds = defaults.objectForKey("userConstellationIds") as NSMutableArray
        }
        
    }
    
    func fetchProfileDetails() {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        self.loadUserDefaultsData()
        var urlPath : String = "http://\(GlobalVariable.apiUrl)/api/accounts/fetch_profile_details.json?api_key=\(apiKey)"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            // Youmitter code
            //            if (jsonResult.objectForKey("comments") != nil) {
            //                let results: NSArray = jsonResult["comments"] as NSArray
            //                println("results = \(results)")
            //            }
            //            else {
            //                println("jsonresult = \(jsonResult)")
            //            }
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        }
    }
    
    func fetchComments(transmissionId: Int, archivedValue: String) {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.loadUserDefaultsData()
        var urlPath : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/fetch_comments.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&archived=\(archivedValue)"
        
        let url = NSURL(string: urlPath)
        println("=======url====\(url)")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            // Youmitter code
            if (jsonResult.objectForKey("comments") != nil) {
                let results: NSArray = jsonResult["comments"] as NSArray
                println("results = \(results)")
            }
            else {
                println("jsonresult = \(jsonResult)")
            }
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        }
        
    }
    
    func searchTransmissions(searchData: String, searchLocation: String, searchCategory: String) {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        println("searchData = \(searchData)")
        println("searchLocation = \(searchLocation)")
        println("searchCategory = \(searchCategory)")
        var data: String, location: String, category: String
        data = join("+", searchData.componentsSeparatedByString(" "))
        location = join("+", searchLocation.componentsSeparatedByString(" "))
        category = join("+", searchCategory.componentsSeparatedByString(" "))
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/transmissions/search.json?api_key=\(apiKey)&location=\(location)&search_text=\(data)&category_id=\(searchCategory)"
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            println("=== Task completed search ====")
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            println("=== jsonResult = \(jsonResult) ===")
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            if (jsonResult.objectForKey("transmissions") != nil)
            {
                
                let results: NSArray = jsonResult["transmissions"] as NSArray!
            }
            else if (jsonResult.objectForKey("result") != nil)
            {
                println("no items found")
                
            }
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            
        })
        
        task.resume()
        }
        
    }
    
    func fetchUserConstellations(api_key: String) {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.loadUserDefaultsData()
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellations/fetch_constellations.json?api_key=\(api_key)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                dispatch_async(dispatch_get_main_queue(), {
                if (jsonResult.objectForKey("constellations") != nil) {
                    var constellations :NSArray = jsonResult["constellations"] as NSArray
                    for constellation in constellations {
                        var eachConstellation: NSDictionary = constellation as NSDictionary
                        //                        println("eachConstellation = \(eachConstellation)")
                        var constellationName: String = eachConstellation["name"] as String
                        var constellationId: Int = eachConstellation["id"] as Int
                        self.userConstellations.addObject(constellationName)
                        self.userConstellationIds.addObject(constellationId)
                    }
                    if let userConstellationsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
                        
                    } else {
                        
                        self.defaults.setObject(self.userConstellations, forKey: "userConstellations")
                        
                    }
                    
                    if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                        
                    } else {
                        
                        self.defaults.setObject(self.userConstellationIds, forKey: "userConstellationIds")
                        //
                    }
                    
                }
                
                
                
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }
    }
    
    func fetchTuneInTransmissions() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.loadUserDefaultsData()
        //        fetchUserConstellations()
        println("===== apikey ====== \(apiKey)")
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        //        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        //        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
        //            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        // Youmitter code
        
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/transmissions/fetch_tuned_in_transmissions.json?&api_key=\(apiKey)"
        
        println("url =================== \(urlPath)")
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            if (jsonResult.objectForKey("transmissions") != nil) {
                let results: NSArray = jsonResult["transmissions"] as NSArray
            }
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
            
        }
    }
    
    func fetchConstellationTransmissions(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.loadUserDefaultsData()
        //        fetchUserConstellations()
        println("===== apikey ====== \(apiKey)")
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        //        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        //        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
        //            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        // Youmitter code
        
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/constellations/view_transmissions.json?&api_key=\(apiKey)&constellation_id=\(id)"
        
        println("url =================== \(urlPath)")
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            if (jsonResult.objectForKey("transmissions") != nil) {
                let results: NSArray = jsonResult["transmissions"] as NSArray
            }
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
            
        }
        
    }
    
    func fetchTransmissions(searchTerm: String, currentPage: Int) {
    
    if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")

        self.loadUserDefaultsData()
        var urlPath: String = ""
        //        fetchUserConstellations()
        println("===== apikey ====== \(apiKey)")
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            //            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
            // Youmitter code
            if currentPage == 0 {
                urlPath = "http://\(GlobalVariable.apiUrl)/api/transmissions/fetch_transmissions.json?tran_cat=\(searchTerm)&direction=desc&api_key=\(apiKey)&trans_type=\(transType)"
            }
            else {
                urlPath = "http://\(GlobalVariable.apiUrl)/api/transmissions/fetch_transmissions.json?tran_cat=\(searchTerm)&direction=desc&api_key=\(apiKey)&trans_type=\(transType)&page=\(currentPage)"
            }
            println("url =================== \(urlPath)")
            // Youmitter code
            let url = NSURL(string: urlPath)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
                
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                //                let results: NSArray = jsonResult["results"] as NSArray
                // Youmitter code
                if (jsonResult.objectForKey("transmissions") != nil) {
                    let results: NSArray = jsonResult["transmissions"] as NSArray
                }
                // Youmitter code
                self.delegate.didReceiveAPIResults(jsonResult)
                println("Task completed ==========")
            })
            
            task.resume()
        }
        
        }
    
    }
    
    
    func fetchConstellations() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        //        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        //        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
        //            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        
        // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/constellations/fetch_constellations.json?api_key=\(apiKey)"
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            if (jsonResult.objectForKey("constellations") != nil)
            {
                
                let results: NSArray = jsonResult["constellations"] as NSArray!
            }
            else
            {
                println("no constellations found")
                
            }
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        //        }
            
        }
    }
    
    func fetchUserInterests() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
                // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/users/list_of_interests.json"
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            if (jsonResult.objectForKey("interests") != nil)
            {
                
                let results: NSArray = jsonResult["interests"] as NSArray!
            }
            else
            {
                println("no results found")
                
            }
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        //        }
            
        }
    }
    
    func fetchThisConstellation(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/constellations/fetch_this_constellation.json?api_key=\(apiKey)&constellation_id=\(id)"
        // Youmitter code
        println("url ====== \(urlPath)")
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
//            if (jsonResult.objectForKey("conversations") != nil)
//            {
//                
//                let results: NSArray = jsonResult["conversations"] as NSArray!
//            }
//            else
//            {
//                println("no results found")
//                
//            }
            
//            let results: NSArray = jsonResult as NSArray!
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()

        }
        
    }
    
    func fetchConstellationMembers(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/constellations/view_members.json?api_key=\(apiKey)&constellation_id=\(id)"
        // Youmitter code
        println("url ====== \(urlPath)")
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            //            if (jsonResult.objectForKey("conversations") != nil)
            //            {
            //
            //                let results: NSArray = jsonResult["conversations"] as NSArray!
            //            }
            //            else
            //            {
            //                println("no results found")
            //
            //            }
            
            //            let results: NSArray = jsonResult as NSArray!
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        
        }
        
    }
    
    func fetchViewRequests(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/constellations/view_user_request.json?api_key=\(apiKey)&constellation_id=\(id)"
        // Youmitter code
        println("url ====== \(urlPath)")
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            //            if (jsonResult.objectForKey("conversations") != nil)
            //            {
            //
            //                let results: NSArray = jsonResult["conversations"] as NSArray!
            //            }
            //            else
            //            {
            //                println("no results found")
            //
            //            }
            
            //            let results: NSArray = jsonResult as NSArray!
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        
        }
        
    }
    
    
    func fetchSeeActivities(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        // Youmitter code
        self.loadUserDefaultsData()
        let urlPath = "http://\(GlobalVariable.apiUrl)/api/conversations/fetch_messages.json?api_key=\(apiKey)&constellation_id=\(id)"
        // Youmitter code
        println("url ====== \(urlPath)")
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error \(err!.localizedDescription)")
            }
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            if (jsonResult.objectForKey("conversations") != nil)
            {
                
                let results: NSArray = jsonResult["conversations"] as NSArray!
            }
            else
            {
                println("no results found")
                
            }
            
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        //        }
            
        }
    }

    
    
    func fetchMessages(url: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        self.loadUserDefaultsData()
        println("===== apikey ====== \(apiKey)")
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        //        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        //        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
        //            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=music"
        // Youmitter code
        
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/conversations/\(url).json?api_key=\(apiKey)"
        
        println("=====url=========\(urlPath)")
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                
                if (jsonResult.objectForKey("conversations") != nil) {
                    let results: NSArray = jsonResult["conversations"] as NSArray
                    //                    println("=============  \(results)  =============")
                }
                // Youmitter code
                self.delegate.didReceiveAPIResults(jsonResult)
                println("Task completed ==========")
                
                
            
                println("=========else========")
                
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error ====== \(err!.localizedDescription)")
//                    self.fetchMessages("fetch_messages")
                }
            
            
            
            
            //                let results: NSArray = jsonResult["results"] as NSArray
            // Youmitter code
            
            
        })
        
        task.resume()
        }
    }
    
    func fetchAlerts(currentPage: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        
        self.loadUserDefaultsData()
        println("===== apikey ====== \(apiKey)")
        // Youmitter code
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/alerts/fetch_alerts.json?api_key=\(apiKey)"
        if currentPage == 0 {
            urlPath = "http://\(GlobalVariable.apiUrl)/api/alerts/fetch_alerts.json?api_key=\(apiKey)"
        }
        else {
            urlPath = "http://\(GlobalVariable.apiUrl)/api/alerts/fetch_alerts.json?api_key=\(apiKey)&page=\(currentPage)"
        }
        
        // Youmitter code
        let url = NSURL(string: urlPath)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url!, completionHandler: {data, response, error -> Void in
            
            if(error != nil) {
                // If there is an error in the web request, print it to the console
                println(error.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            
            if(err != nil) {
                println("JSON Error \(err!.localizedDescription)")
            }
            
            // Youmitter code
            if (jsonResult.objectForKey("alerts") != nil) {
                let results: NSArray = jsonResult["alerts"] as NSArray
                
            }
            // Youmitter code
            self.delegate.didReceiveAPIResults(jsonResult)
            println("Task completed ==========")
        })
        
        task.resume()
        
        }
        
    }
}
