//
//  ConversationListViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 27/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController,  APIControllerProtocol, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var messageListTableView: UITableView!
    @IBOutlet var replyMessageTextField: UITextField!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    let kCellIdentifier: String = "messageCell"
    var conversationDetails: NSDictionary!
    var messageList: NSArray!
    var conversationId: Int = 0
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
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        api = APIController(delegate: self)
        api!.delegate = self
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        self.sideMenuController()?.sideMenu?.delegate = self;
        messageList = conversationDetails["messages"] as NSArray
        conversationId = conversationDetails["id"] as Int
        println("messageList = \(messageList)")
    }

    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        markReadConversation()
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
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    func markReadConversation() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var urlPath = "http://\(GlobalVariable.apiUrl)/api/conversations/mark_as_read_conversation.json?api_key=\(apiKey)&conversation_ids=\(self.conversationId)"
        
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
            
//            if (jsonResult.objectForKey("conversations") != nil) {
//                let results: NSArray = jsonResult["conversations"] as NSArray
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
    
    @IBAction func replyButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var body = join("+", replyMessageTextField.text.componentsSeparatedByString(" "))
        if body != "" {
            var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/reply_to_message.json?api_key=\(apiKey)&conversation_id=\(conversationId)&body=\(body)"
            var request : NSMutableURLRequest = NSMutableURLRequest()
            request.URL = NSURL(string: url)
            //        request.HTTPMethod = "POST"
            
            dispatch_async(dispatch_get_main_queue()) {
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
            }
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
                let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
                println("==== jsonResult === \(jsonResult) =======")
                if (jsonResult != nil) {
                    
                    println("====== \(jsonResult) ======")
                    // process jsonResult
                    //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                    var commentId :NSString? = jsonResult?.valueForKey("message_id") as? NSString
                    if jsonResult?.valueForKey("message_id") != nil {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Message Added successfully", preferredStyle: UIAlertControllerStyle.Alert)
                            //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                
                                self.replyMessageTextField.text = ""
                                
                                if Reachability.isConnectedToNetwork() == true {
                                    println("Internet connection OK")
                                    
                                    self.activityIndicatorView.startAnimating()
                                    self.activityIndicatorView.hidden = false
                                    self.view.userInteractionEnabled = false
                                
                                    self.api!.fetchMessages("fetch_messages")
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
                        var errorMessage: NSDictionary = (jsonResult["validations"] as NSDictionary)
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
            })
            
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "", message: "Message can't be blank.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return messageList.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: ConversationListViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as ConversationListViewCell
        //        var myColor : UIColor = UIColor( red: 1, green: 0, blue:0, alpha: 1.0 )
        //        cell.contentView.layer.borderColor = myColor.CGColor
        var message: NSDictionary = messageList[indexPath.row] as NSDictionary
        cell.nameLabel.text = message["sender_name"] as? String
        cell.messageLabel.text = message["body"] as? String
        cell.dateLabel.text = message["created_at"] as? String
        cell.moreButton.tag = indexPath.row
        
        var senderImageString: String = (message["sender_image"] as     String)
        let imgURL: NSURL? = NSURL(string: senderImageString)
        
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var senderImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    cell.senderImageView.image = senderImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        messageListTableView.deselectRowAtIndexPath(indexPath, animated: true)
        println("====row selected=====")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessage" {
            
            var detailsViewController: MessageDetailsViewController = segue.destinationViewController as MessageDetailsViewController
            var messageIndex = sender?.tag
            
            detailsViewController.messageDetails = self.messageList.objectAtIndex(messageIndex!) as NSDictionary
            detailsViewController.conversationId = self.conversationId
            detailsViewController.hidesBottomBarWhenPushed = true
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        if results.objectForKey("conversations") != nil {
            var resultsArr: NSArray = results["conversations"] as NSArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                
               
                for i in 0..<resultsArr.count {
                    var eachConversation: NSDictionary = resultsArr[i] as NSDictionary
                    var eachConversationId: Int = eachConversation["id"] as Int
                    if eachConversationId == self.conversationId {
                        self.messageList = eachConversation["messages"] as NSArray
                    }
                }
                
                self.messageListTableView!.reloadData()
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
            })
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
        
        self.navigationController?.pushViewController(destViewController, animated: true)
        
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
