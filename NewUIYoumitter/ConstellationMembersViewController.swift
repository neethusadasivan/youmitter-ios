//
//  ConstellationMembersViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 06/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ConstellationMembersViewController: UIViewController, APIControllerProtocol {

    
    @IBOutlet var membersTableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    
    var api: APIController?
    let kCellIdentifier: String = "membersCell"
    var apiKey: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var constellationId: Int = 0
    var membersData = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.membersTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        println("constellation id ==== \(self.constellationId)")
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
            api!.fetchConstellationMembers(self.constellationId)
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
        println("membersData count = \(membersData.count)")
        return membersData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell: ViewMembersTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as ViewMembersTableViewCell
        
        let rowData: NSDictionary = self.membersData[indexPath.row] as NSDictionary
        
        //        cell.abusiveButton.tag = rowData["id"] as Int
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        cell.removeButton.tag = rowData["id"] as Int!
        cell.removeImageButton.tag = rowData["id"] as Int!
        
        cell.memberNameLabel.text = rowData["user_title"] as? String
        //        cell.timeText.text = rowData["created_at"] as? String
        //        cell.bodyContentText?.text = rowData["body"] as? String
        
                let userImageString: NSString = rowData["image"] as NSString!
                //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
        
                let imgURL: NSURL? = NSURL(string: userImageString)
                //        let imgData = NSData(contentsOfURL: imgURL!)
                //        if imgData != nil {
                //            cell.userImageView.image = UIImage(data: imgData!)
                //        }
        
                let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        var userImage = UIImage(data: data)
        
                        // Store the image in to our cache
                        dispatch_async(dispatch_get_main_queue(), {
        
                            cell.memberImageView.image = userImage
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
        var isAdmin = rowData["is_admin"] as? String
        if isAdmin == "yes" {
            cell.adminIcon.hidden = false
        }
        else {
            cell.adminIcon.hidden = true
            
        }
        
        return cell
    }

    func didReceiveAPIResults(results: NSDictionary) {
        
        println("results ======= \(results)")
        if results.objectForKey("consellation_member") != nil {
            println("request not nil")
            var resultsArr: NSArray = results["consellation_member"] as NSArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.membersData = resultsArr
                self.membersTableView!.reloadData()
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                
            })
            
        }
        else {
            println("request not nil else")
            if results.objectForKey("error") != nil {
                //                var error: NSString = results["error"] as NSString
                let alertController = UIAlertController(title: "", message: "No members found", preferredStyle: UIAlertControllerStyle.Alert)
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
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellation_users/remove_user.json?api_key=\(apiKey)&constellation_user_id=\(sender.tag)"
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
                if jsonResult?.valueForKey("notification") != nil {
                    var message :NSString? = jsonResult?.valueForKey("notification") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Constellation member removed.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                            
                                self.api!.fetchConstellationMembers(self.constellationId)
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
            } else {
                println(" === nil ==== ")
                dispatch_async(dispatch_get_main_queue()) {
                    // couldn't load JSON, look at error
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                
            }
            
        })
        dispatch_async(dispatch_get_main_queue()) {
            // couldn't load JSON, look at error
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.view.userInteractionEnabled = true
        }
        }
    }

    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    @IBAction func searchMenuClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

    @IBAction func messagesMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
//        unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertsMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
//        unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    
}
