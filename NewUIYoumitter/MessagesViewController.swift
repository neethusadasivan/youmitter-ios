
//  MessagesViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 26/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {
    
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var messagesTableView: UITableView!
    @IBOutlet var messageSegmentController: UISegmentedControl!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var unreadMessageLabel: UILabel!
    
    var currentPage: Int = 0
    
    var fromNewConversation = false
    var messagesData: NSMutableArray = []
    var api:APIController?
    let kCellIdentifier: String = "messageCell"
    var imageCache = [String : UIImage]()
    var apiKey: String = ""
    var receivedData : NSMutableArray = NSMutableArray()
    var sentData : NSMutableArray = NSMutableArray()
    var favoritedData : NSMutableArray = NSMutableArray()
    var mutedData : NSMutableArray = NSMutableArray()
    var selectedTab: String = "fetch_messages"
    var imgData: NSData?
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        
//        if fromNewConversation == true {
//            messageSegmentController.selectedSegmentIndex = 1
//            fromNewConversation = false
//        }
        
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
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
            api!.fetchMessages("fetch_messages")
        }
        //        parseConversations()
        api!.delegate = self
        //        parseConversations()
    }

    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeMessageSegments(sender: AnyObject) {
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        switch messageSegmentController.selectedSegmentIndex {
        case 0:
            self.selectedTab = "fetch_messages"
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchMessages("fetch_messages")
            }
            
            //            self.messagesData = receivedData
            self.messagesTableView!.reloadData()
        case 1:
            self.selectedTab = "fetch_messages"
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchMessages("fetch_messages")
            }
            //            self.messagesData = sentData
            
            self.messagesTableView!.reloadData()
        case 2:
            self.selectedTab = "favorited"
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
            api!.fetchMessages("favorited")
            }
            //            self.messagesData = favoritedData
            self.messagesTableView!.reloadData()
        case 3:
            self.selectedTab = "muted"
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
            api!.fetchMessages("muted")
            }
            //            self.messagesData = mutedData
            self.messagesTableView!.reloadData()
        default:
            break
        }
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
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
    
    
    
    @IBAction func favoriteButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/toggle_favorite_conversation.json?api_key=\(apiKey)&conversation_id=\(sender.tag)"
        println("===========\(url)")
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
                if jsonResult?.valueForKey("conversation_favorited") != nil {
                    var message :NSString? = jsonResult?.valueForKey("conversation_favorited") as? NSString
                    var displayMessage: String = ""
                    if message == "true" {
                        displayMessage = "Message marked as favorite."
                    }
                    else if message == "false" {
                        displayMessage = "Message marked as unfavorite."
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(displayMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.api!.fetchMessages(self.selectedTab)
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
                else if jsonResult?.valueForKey("error") != nil {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
                        }
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                else {
                    println("======== else part ========")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
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
    
    @IBAction func muteButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var title = sender.titleForState(.Normal)
        println("button title = \(title)")
        var url : String = ""
        if title == " Mute" {
            url = "http://\(GlobalVariable.apiUrl)/api/conversations/mute_conversation.json?api_key=\(apiKey)&conversation_ids=\(sender.tag)"
        }
        else if title == " Unmute" {
            url = "http://\(GlobalVariable.apiUrl)/api/conversations/unmute_conversation.json?api_key=\(apiKey)&conversation_ids=\(sender.tag)"
        }
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
                if jsonResult?.valueForKey("conversation") != nil {
                    var message :NSString? = jsonResult?.valueForKey("conversation") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(message!)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.api!.fetchMessages(self.selectedTab)
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
                else if jsonResult?.valueForKey("error") != nil {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.api!.fetchMessages(self.selectedTab)
                            }
                            println("Ok Pressed")
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                else {
                    println("======== else part ========")
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
                
            }
            
        })
            
        }
    }
    
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/delete_conversation.json?api_key=\(apiKey)&conversation_ids=\(sender.tag)"
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
                if jsonResult?.valueForKey("conversation") != nil {
                    var message :NSString? = jsonResult?.valueForKey("conversation") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Conversation message has been deleted!", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.messageSegmentController.selectedSegmentIndex = 0
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.api!.fetchMessages(self.selectedTab)
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
                        let alertController = UIAlertController(title: "", message: "Conversation message cannot be deleted", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
                
            }
            
            
        })
        
        }
    }
    
    func parseConversations() {
        
        //        if let eachConversation = messagesData {
        
        //            var array_list : NSMutableArray! =  NSMutableArray(eachConversation:eachConversation)
        var array_list_category_name : NSMutableArray = NSMutableArray()
        //
        receivedData.removeAllObjects()
        sentData.removeAllObjects()
        for item in messagesData {
            var dic_item : NSDictionary! = item as NSDictionary
            //                var favorited = dic_item["favorited"] as? String
            //                    if favorited == "true" {
            //                        favoritedData.addObject(dic_item)
            //                    }
            //                var muted = dic_item["muted"] as? String
            //                    if muted == "true" {
            //                        mutedData.addObject(dic_item)
            //                    }
            var messages :NSArray = dic_item["messages"] as NSArray
            var lastMessage :NSDictionary = (messages[messages.count - 1] as? NSDictionary)!
            var ifReceived :String = lastMessage["received"] as String
            if (ifReceived == "true") {
                println("received true")
                receivedData.addObject(dic_item)
            }
            if (ifReceived == "false") {
                println("received false")
                sentData.addObject(dic_item)
            }
        }
        
        if self.messageSegmentController.selectedSegmentIndex == 0 {
            if self.currentPage == 0 {
                messagesData = receivedData
            }
            else {
                self.messagesData.addObjectsFromArray(receivedData.subarrayWithRange(NSMakeRange(0, receivedData.count)))
            }
        }
        else if self.messageSegmentController.selectedSegmentIndex == 1 {
            if self.currentPage == 0 {
                messagesData = sentData
            }
            else {
                self.messagesData.addObjectsFromArray(sentData.subarrayWithRange(NSMakeRange(0, sentData.count)))
            }
        }
        
        
        //        }
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return messagesData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: MessageTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as MessageTableViewCell
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        if (messagesData.count == 0) {
            println("inside if count = 0")
            let alertController = UIAlertController(title: "", message: "No Data Found.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            println("outside if count = 0")
            let rowData: NSDictionary = self.messagesData[indexPath.row] as NSDictionary
            
            cell.messageButton.tag = rowData["id"] as Int
            cell.muteButton.tag = rowData["id"] as Int
            cell.deleteButton.tag = rowData["id"] as Int
            cell.favouriteButton.tag = rowData["id"] as Int
            
            var favorited: String = ""
            var muted: String = ""
            favorited = rowData["favorited"] as String
            muted = rowData["muted"] as String
            var msgRead = rowData["status"] as String
            println("===msgRead====\(msgRead)")
            
            if (msgRead == "read") {
                cell.messageView.backgroundColor = UIColor(red: (242/255.0), green: (242/255.0), blue: (242/255.0), alpha:1.0)
            }
            else {
                cell.messageView.backgroundColor = UIColor.whiteColor()
            }

            if favorited == "true" {
                let favoriteImage = UIImage(named: "ic_action_important.png") as UIImage?
                cell.favouriteButton.setImage(favoriteImage, forState: .Normal)
            }
            else {
                let favoriteImage = UIImage(named: "ic_action_not_important.png") as UIImage?
                cell.favouriteButton.setImage(favoriteImage, forState: .Normal)
            }
            
            if muted == "true" {
                cell.muteButton.setTitle(" Unmute", forState: UIControlState.Normal)
            }
            else {
                cell.muteButton.setTitle(" Mute", forState: UIControlState.Normal)
            }
            
            
            let messages: NSArray = (rowData["messages"] as? NSArray)!
            var lastMessage: NSDictionary = (messages[messages.count - 1] as? NSDictionary)!
            cell.messageButton.setTitle(" \(messages.count)", forState: UIControlState.Normal)
            var senderImageString: String = (lastMessage["sender_image"] as String)
           
            var received = lastMessage["received"] as? String
            //        if received == "true" {
            cell.bodyLabel.text = lastMessage["body"] as? String
            cell.userNamelabel?.text = lastMessage["sender_name"] as? String
            cell.timeLabel?.text = lastMessage["created_at"] as? String
            
            
            let imgURL: NSURL? = NSURL(string: senderImageString)
//            imgData = NSDaphotta(contentsOfURL: imgURL!)
//            if imgData != nil {
//                cell.userImageView.image = UIImage(data: imgData!)
//            }
            
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

            
            
            //        }
            //        }
        }
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageDetail" {
            
            var detailsViewController: ConversationListViewController = segue.destinationViewController as ConversationListViewController
            var messageIndex = self.messagesTableView.indexPathForSelectedRow()!
            
            detailsViewController.conversationDetails = self.messagesData.objectAtIndex(messageIndex.row) as NSDictionary
            detailsViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    func connection(connection: NSURLConnection!, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace!) -> Bool  {
        return true
    }
    
    func connection(connection: NSURLConnection!, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge!) {
        challenge.sender.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust), forAuthenticationChallenge: challenge)
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        // Youmitter code
        
        if results.objectForKey("conversations") != nil {
            var resultsArr: NSMutableArray = results["conversations"] as NSMutableArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.currentPage == 0 {
                    self.messagesData = resultsArr
                    if self.selectedTab == "fetch_messages" {
                        
                        self.parseConversations()
                        println("\nmessagesdata======\(self.messagesData)")
                        if (self.messagesData.count == 0) {
                            let alertController = UIAlertController(title: "", message: "No messages found", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                    self.messagesTableView!.reloadData()
                }
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            })
        }
        else if results.objectForKey("conversation") != nil {
            self.messagesData = []
            self.messagesTableView!.reloadData()
            var error: NSString = results["conversation"] as NSString
            let alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
            
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                println("lllllllllll")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.messagesData = []
                    self.messagesTableView!.reloadData()
                })
            let alertController = UIAlertController(title: "", message: "No messages found.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                self.messageSegmentController.selectedSegmentIndex = 0
            }
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func searchMenuClicked(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        alertNotification.setMessageCountAsRead()
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

    
}
