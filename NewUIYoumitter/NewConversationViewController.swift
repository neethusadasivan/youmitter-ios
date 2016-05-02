//
//  NewConversationViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 09/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class NewConversationViewController: UIViewController, UITextViewDelegate, APIControllerProtocol {

   
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var fromNameLabel: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var toUserNameText: UITextField!
    @IBOutlet var messageBodyTextView: UITextView!
    @IBOutlet var fromUserImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    var alertNotification = NotificationCount()
    
    var apiKey :String = ""
    var api: APIController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageBodyTextView.delegate = self
        messageBodyTextView.textColor = UIColor.lightGrayColor()
        messageBodyTextView.selectedTextRange = messageBodyTextView.textRangeFromPosition(messageBodyTextView.beginningOfDocument, toPosition: messageBodyTextView.beginningOfDocument)
        
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
        api!.loadUserDefaultsData()
        api!.delegate = self
        apiKey = api!.apiKey
        messageBodyTextView.delegate = self
        fromNameLabel.text = api!.userName
        let urlString: String = api!.imageUrl as String
        let imgURL: NSURL? = NSURL(string: urlString)
        
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var userImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.fromUserImageView.image = userImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        
//        let imgURL: NSURL? = NSURL(string: urlString)
//        let imgData = NSData(contentsOfURL: imgURL!)
//        fromUserImageView.image = UIImage(data: imgData!)
        
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
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        if self.view.window != nil {
            if messageBodyTextView.textColor == UIColor.lightGrayColor() {
                messageBodyTextView.selectedTextRange = messageBodyTextView.textRangeFromPosition(messageBodyTextView.beginningOfDocument, toPosition: messageBodyTextView.beginningOfDocument)
            }
        }
        
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: NSString = messageBodyTextView.text
        let updatedText: NSString = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.length == 0 {
            
            messageBodyTextView.text = "Say whats on your mind, its completely anonymous, and its free."
            messageBodyTextView.textColor = UIColor.lightGrayColor()
            
            messageBodyTextView.selectedTextRange = messageBodyTextView.textRangeFromPosition(messageBodyTextView.beginningOfDocument, toPosition: messageBodyTextView.beginningOfDocument)
            
        }
        else if messageBodyTextView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            messageBodyTextView.text = nil
            messageBodyTextView.textColor = UIColor.blackColor()
        }
        
        
        return true
    }
    
    func checkForBlankRecipientAndMessage() -> String  {
        var message: String = "NoBlank"
        if (toUserNameText.text == "" && messageBodyTextView.text == "Say whats on your mind, its completely anonymous, and its free.") {
            println("====both blank======")
            message = "Recipient and message can't be blank."
        }
        else if(toUserNameText.text == "") {
            println("====toUserNameText blank======")
            message = "Recipient can't be blank."
        }
        else if(messageBodyTextView.text == "Say whats on your mind, its completely anonymous, and its free.") {
            println("====messageBodyTextView blank======")
            message = "Message can't be blank."
        }
        return message
        
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        
        
        var message = checkForBlankRecipientAndMessage()
        println("=======message====\(message)")
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
            self.activityIndicatorView.startAnimating()
            self.view.userInteractionEnabled = false

        if (message == "NoBlank") {
            
        
        var messageBody = ""
        if messageBodyTextView.text != "Say whats on your mind, its completely anonymous, and its free." {
            messageBody = join("+", messageBodyTextView.text.componentsSeparatedByString(" "))
        }
        var recipientUsername = join("+", toUserNameText.text.componentsSeparatedByString(" "))
        
        //        conversations/new_message.json?api_key="+Globals.apiKey+"&recipient_username="+userName+"&message="+messageBody
        var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/new_message.json?api_key=\(apiKey)&recipient_username=\(recipientUsername)&message=\(messageBody)"
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
                var conversationId :NSString? = jsonResult?.valueForKey("conversation_id") as? NSString
                if jsonResult?.valueForKey("conversation_id") != nil {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Conversation Added successfully", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            self.toUserNameText.text = ""
                            self.messageBodyTextView.text = "Say whats on your mind, its completely anonymous, and its free."
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
//                            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//                            var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
//                            destViewController.hidesBottomBarWhenPushed = true
////                            destViewController.fromNewConversation = true
//                            self.navigationController?.pushViewController(destViewController, animated: true)
                            
                            self.navigationController?.popViewControllerAnimated(true)
// //                           self.dismissViewControllerAnimated(true, completion: nil)
                            println("Ok Pressed")
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("validations") != nil  {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["validations"] as NSDictionary)
                    var displayMessage = errorMessage["1"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(displayMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                        alertController.addAction(okAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                println(" === nil  \(jsonResult)==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            
        })
        
        }
            
        }else {
            
            var alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
            //Creating actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                
                
                println("Ok Pressed")
            }
            //Creating actions
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
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
