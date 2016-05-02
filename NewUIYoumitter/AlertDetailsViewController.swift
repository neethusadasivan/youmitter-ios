//
//  AlertDetailsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 28/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class AlertDetailsViewController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var alertTypeLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var remindMeButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    
    var alertId: Int = 0
    var alertDetails:NSDictionary!
    var api: APIController?
    var apiKey: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.sideMenuController()?.sideMenu?.delegate = self;
        
        println("alert details controller")
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        api!.delegate = self
        println("alert details = \(alertDetails)")
        alertTypeLabel.text = alertDetails["alertable_type"] as? String
        timeLabel.text = alertDetails["created_at"] as? String
        bodyLabel.text = alertDetails["message"] as? String
        alertId = alertDetails["id"] as Int

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        markReadAlert()
    }

    func markReadAlert() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/alerts/mark_as_read_alert.json?api_key=\(apiKey)&alert_ids=\(self.alertId)"
        
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
            
//            if (jsonResult.objectForKey("alerts") != nil) {
//                let results: NSArray = jsonResult["alerts"] as NSArray
//                //                    println("=============  \(results)  =============")
//            }
//            // Youmitter code
            
            println("Task completed ==========")
            
            
            
            println("=========else========")
            
            if(err != nil) {
                // If there is an error parsing JSON, print it to the console
                println("JSON Error ====== \(err!.localizedDescription)")
                //                    self.fetchMessages("fetch_messages")
            }
            
        })
        
        task.resume()
        }
    }
    
    @IBAction func sideMenuClicked(sender: AnyObject) {
        toggleSideMenuView()
    }
    
    // MARK: - ENSideMenu Delegate
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return true;
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    
    @IBAction func remindMeButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var url : String = "http://\(GlobalVariable.apiUrl)/api/alerts/remind_alert.json?api_key=\(apiKey)&alert_ids=\(alertId)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("alert") != nil {
                    var message :NSString? = jsonResult?.valueForKey("alert") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Added to remind later", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }
        
    }
    
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var url : String = "http://\(GlobalVariable.apiUrl)/api/alerts/dismiss_alert.json?api_key=\(apiKey)&alert_ids=\(alertId)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("alert") != nil {
                    var message :NSString? = jsonResult?.valueForKey("alert") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Dismissed successfully", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchAlerts()
                            
                            self.navigationController?.popViewControllerAnimated(true)
//                            self.dismissViewControllerAnimated(true, completion: {})
//                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                            var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
//                            destViewController.hidesBottomBarWhenPushed = true
//                            
//                            self.presentViewController(destViewController, animated: true, completion: nil)
//                            
//                            println("Ok Pressed")
                            return
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Alert cannot be dismissed", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }

    }
    
    func didReceiveAPIResults(results: NSDictionary) {
    }
 
    @IBAction func searchMenuClicked(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

}
