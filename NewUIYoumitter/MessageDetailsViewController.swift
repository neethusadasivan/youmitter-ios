//
//  MessageDetailsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 28/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MessageDetailsViewController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {

    
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var fromUserlabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var replyMessageTextField: UITextField!
    @IBOutlet var alertMenuButton: UIBarButtonItem!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    
    var messageDetails: NSDictionary!
    var conversationId: Int = 0
    var api: APIController?
    var apiKey :String = ""
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
        
        var label = UILabel(frame: CGRectMake(0, 0, 30, 30))
//        label.center = CGPointMake(160, 284)
        label.text = "5"
        label.textAlignment = NSTextAlignment.Center
//        self.sideMenuButton
        
        self.sideMenuController()?.sideMenu?.delegate = self;
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        println("message details = \(messageDetails)")
        fromUserlabel.text = messageDetails["sender_name"] as? String
        timeLabel.text = messageDetails["created_at"] as? String
        bodyLabel.text = messageDetails["body"] as? String
        
        
        var senderImageString: String = (messageDetails["sender_image"] as String)
        let imgURL: NSURL? = NSURL(string: senderImageString)
  
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var userImageData = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.userImage.image = userImageData
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        
       
    }

    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
                                //                                self.api!.fetchComments(self.transmissionId)
                                self.replyMessageTextField.text = ""
                                
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                                
                                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                                var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
                                destViewController.hidesBottomBarWhenPushed = true
                                
                                self.navigationController?.pushViewController(destViewController, animated: true)
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
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }


}
