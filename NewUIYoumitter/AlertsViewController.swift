//
//  AlertsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 27/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class AlertsViewController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {
    
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var alertsTableView: UITableView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    
    var alertsData: NSMutableArray = []
    var api: APIController?
    let kCellIdentifier: String = "alertCell"
    var apiKey: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        unreadMessageLabel.layer.cornerRadius = 8
        unreadAlertLabel.layer.cornerRadius = 8
        unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
//        self.alertsTableView.delegate = self
//        self.alertsTableView.dataSource = self
        
        self.sideMenuController()?.sideMenu?.delegate = self;
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            //        self.view.userInteractionEnabled = false
            api!.fetchAlerts(0)
        }
        api!.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.tabBarController?.tabBar.hidden = true
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            api!.fetchAlerts(0)
        }
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
    }
    
    @IBAction func remindLaterButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var url : String = "http://\(GlobalVariable.apiUrl)/api/alerts/remind_alert.json?api_key=\(apiKey)&alert_ids=\(sender.tag)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
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
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
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
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            
            
        })
            
        }
    }
    
    @IBAction func deleteAlertButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/alerts/dismiss_alert.json?api_key=\(apiKey)&alert_ids=\(sender.tag)"
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
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                                self.api!.fetchAlerts(0)
                            }
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
                        let alertController = UIAlertController(title: "", message: "Alert cannot be dismissed", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        })
            
        }
    }
    
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return alertsData.count
    }

    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: AlertsCustomTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as AlertsCustomTableViewCell
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        let rowData: NSDictionary = self.alertsData[indexPath.row] as NSDictionary
        
        cell.messageLabel.text = rowData["message"] as? String
        cell.alertTypeLabel.text = rowData["alertable_type"] as? String
        cell.remindLaterButton.tag = rowData["id"] as Int
        cell.deleteAlertButton.tag = rowData["id"] as Int
        
        cell.alertView.tag = indexPath.row
        
        var alertRead = rowData["read_status"] as String
        println("===alertRead====\(alertRead)")
        
        if (alertRead == "read") {
            cell.alertView.backgroundColor = UIColor(red: (242/255.0), green: (242/255.0), blue: (242/255.0), alpha:1.0)
        }
        else {
            cell.alertView.backgroundColor = UIColor.whiteColor()
        }

//        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("alertCellTapped:"))
//        cell.alertView.addGestureRecognizer(tapGestureRecognizer)
        
        return cell

    }
    
    func alertCellTapped(sender: UITapGestureRecognizer) {

        var rowIndex: Int = sender.view?.tag as Int!
        println("sender.tag === \(sender.view?.tag)")
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let alertDetailsViewController = storyBoard.instantiateViewControllerWithIdentifier("alertDetailsController") as AlertDetailsViewController
        alertDetailsViewController.alertDetails = self.alertsData.objectAtIndex(rowIndex) as NSDictionary
        alertDetailsViewController.hidesBottomBarWhenPushed = true
        self.presentViewController(alertDetailsViewController, animated:true, completion:nil)
        
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UITableViewCell
        println("=========clicked in did select row ==========")
        
//        cell.accessoryType = .Checkmark
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var row = indexPath.row
        //        prinltn("displaying content = \(universeData)")
        if row == alertsData.count-1 {
            self.currentPage += 1
            println("Reaches end")
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchAlerts(currentPage)
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
            }
        }
        else {
            println("row = \(row)")
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        println("=========clicked in row ==========")
        if segue.identifier == "alertDetail" {
            
            var detailsViewController: AlertDetailsViewController = segue.destinationViewController as AlertDetailsViewController
            var messageIndex = self.alertsTableView.indexPathForSelectedRow()!
            
            detailsViewController.alertDetails = self.alertsData.objectAtIndex(messageIndex.row) as NSDictionary
            detailsViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        // Youmitter code
        if results.objectForKey("alerts") != nil {
            var resultsArr: NSMutableArray = results["alerts"] as NSMutableArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.currentPage == 0 {
                    self.alertsData = resultsArr
                    self.alertsTableView!.reloadData()
                }
                else {
                    //                    self.universeData.append(resultsArr)
                    println("========currentPage========\(self.currentPage)")
                    self.alertsData.addObjectsFromArray(resultsArr.subarrayWithRange(NSMakeRange(0, resultsArr.count)))
                    self.alertsTableView!.reloadData()
                }
                
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            })
            
        }
        else {
            if results.objectForKey("alert") != nil {
                if alertsData.count == 0 {
                    var error: NSString = results["alert"] as NSString
                    let alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                })
            }
        }
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
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

}
