//
//  SeeActivityViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 05/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SeeActivityViewController: UIViewController, APIControllerProtocol {

    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var seeActivityTableView: UITableView!
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    
    var api: APIController?
    let kCellIdentifier: String = "seeActivityCell"
    var apiKey: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var constellationId: Int = 0
    var seeActivityData = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.seeActivityTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        self.seeActivityTableView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)

        
        println("constellation id ==== \(self.constellationId)")
        
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
        
            api!.fetchSeeActivities(self.constellationId)
        }
        api!.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("seeActivityData count = \(seeActivityData.count)")
        return seeActivityData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell: SeeActivityTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as SeeActivityTableViewCell
        let rowData: NSDictionary = self.seeActivityData[indexPath.row] as NSDictionary
        
//        cell.abusiveButton.tag = rowData["id"] as Int
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        let messages: NSArray = (rowData["messages"] as? NSArray)!
        var lastMessage: NSDictionary = (messages[messages.count - 1] as? NSDictionary)!
//        cell.messageButton.setTitle("\(messages.count)", forState: UIControlState.Normal)
//        var senderImageString: String = (lastMessage["sender_image"] as String)
        
        cell.userNameText.text = lastMessage["sender_name"] as? String
        cell.timeText.text = lastMessage["created_at"] as? String
        cell.bodyContentText?.text = lastMessage["body"] as? String
        
        let senderImageString: NSString = lastMessage["sender_image"] as NSString!
        //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
        
        let imgURL: NSURL? = NSURL(string: senderImageString)
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
                    
                    cell.userImageView.image = userImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        return cell
    }

    
    func didReceiveAPIResults(results: NSDictionary) {
        
        println("results ======= \(results)")
        if results.objectForKey("conversations") != nil {
            println("messages not nil")
            var resultsArr: NSArray = results["conversations"] as NSArray
                // Youmitter code
                //        var resultsArr: NSArray = results["results"] as NSArray
                dispatch_async(dispatch_get_main_queue(), {
                    self.seeActivityData = resultsArr
                    self.seeActivityTableView!.reloadData()
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                
                })
            
        }
        else {
            println("message not nil else")
            if results.objectForKey("conversation") != nil {
                var error: NSString = results["conversation"] as NSString
                let alertController = UIAlertController(title: "", message: "Conversations not found", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
//        unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
//        unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
}
