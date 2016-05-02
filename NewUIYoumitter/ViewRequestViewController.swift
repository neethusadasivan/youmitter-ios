//
//  ViewRequestViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 06/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ViewRequestViewController: UIViewController, APIControllerProtocol {

    @IBOutlet var requestTableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    
    var api: APIController?
    let kCellIdentifier: String = "requestCell"
    var apiKey: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var constellationId: Int = 0
    var requestData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.requestTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        println("constellation id ==== \(self.constellationId)")
        
//        self.requestTableView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
        
            api!.fetchViewRequests(self.constellationId)
        }
        api!.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
      
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("request count = \(requestData.count)")
        return requestData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell: ViewRequestTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as ViewRequestTableViewCell
        let rowData: NSDictionary = self.requestData[indexPath.row] as NSDictionary
        
        //        cell.abusiveButton.tag = rowData["id"] as Int
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        cell.removeTextButton.tag = rowData["id"] as Int
        cell.removeImageButton.tag = rowData["id"] as Int
        cell.acceptTextButton.tag = rowData["id"] as Int
        cell.acceptImageButton.tag = rowData["id"] as Int
        
        cell.userNameLabel.text = rowData["nickname"] as? String
//        cell.timeText.text = rowData["created_at"] as? String
//        cell.bodyContentText?.text = rowData["body"] as? String
        
//        let senderImageString: NSString = lastMessage["sender_image"] as NSString!
//        //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
//        
//        let imgURL: NSURL? = NSURL(string: senderImageString)
//        //        let imgData = NSData(contentsOfURL: imgURL!)
//        //        if imgData != nil {
//        //            cell.userImageView.image = UIImage(data: imgData!)
//        //        }
//        
//        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//            if error == nil {
//                var userImage = UIImage(data: data)
//                
//                // Store the image in to our cache
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    cell.userImageView.image = userImage
//                })
//            }
//            else {
//                println("Error: \(error.localizedDescription)")
//            }
//        })
        
        return cell
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        println("results ======= \(results)")
        if results.objectForKey("constellation_user") != nil {
            println("request not nil")
            var resultsArr: NSArray = results["constellation_user"] as NSArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.requestData = resultsArr
                self.requestTableView!.reloadData()
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                
            })
            
        }
        else {
            println("request not nil else")
            if results.objectForKey("error") != nil {
//                var error: NSString = results["error"] as NSString
                let alertController = UIAlertController(title: "", message: "No constellation request found", preferredStyle: UIAlertControllerStyle.Alert)
                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                alertController.addAction(okAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.view.userInteractionEnabled = true
        }
        
    }

    
    
    @IBAction func removeButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellation_users/accept_or_reject_user.json?api_key=\(apiKey)&constellation_user_id=\(sender.tag)&perform=reject"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        println("=====url=====\(url)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("constellation_user") != nil {
                    var message :NSString? = jsonResult?.valueForKey("constellation_user") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Constellation member rejected.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                            
                                self.api!.fetchViewRequests(self.constellationId)
                            }
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                }
                else {
                    println("======== else part ========")
                    if jsonResult?.valueForKey("error") != nil {
                        var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                        var message: String = errorMessage["1"] as String
                        if message == "You dont have admin rights in this constellation." {
                            dispatch_async(dispatch_get_main_queue()) {
                                let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    println("Ok Pressed")
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                    
                                    
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                            
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                let alertController = UIAlertController(title: "", message: "Constellation member can't be removed", preferredStyle: UIAlertControllerStyle.Alert)
                            
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    println("Ok Pressed")
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                
                                
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                
            }
            
        })
            
        }
        
    }
    
    
    @IBAction func acceptButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellation_users/accept_or_reject_user.json?api_key=\(apiKey)&constellation_user_id=\(sender.tag)&perform=accept"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        println("=====url=====\(url)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("constellation_user") != nil {
                    var message :NSString? = jsonResult?.valueForKey("constellation_user") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Constellation member approved.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                            
                                self.api!.fetchViewRequests(self.constellationId)
                            }
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                }
                else {
                    println("======== else part ========")
                    if jsonResult?.valueForKey("error") != nil {
                        var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                        var message: String = errorMessage["1"] as String
                        if message == "You dont have admin rights in this constellation." {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
                                
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    println("Ok Pressed")
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                    
                                    
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                            
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()) {
                                let alertController = UIAlertController(title: "", message: "Constellation member can't be removed", preferredStyle: UIAlertControllerStyle.Alert)
                            
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    println("Ok Pressed")
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                
                                
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.hidden = true
                        self.view.userInteractionEnabled = true
                    }
              
                
            }
            
        })
            
        }
        
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func messageButtonClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
//        unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertButtonClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
//        unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    
}
