//
//  CommentsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 28/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, APIControllerProtocol, ENSideMenuDelegate, UITextViewDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var commentsTableView: UITableView!
    @IBOutlet var newCommentText: UITextField!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var newCommentTextView: UITextView!
    
    var transmissionId: Int = 0
    var archived: String = "false"
    var api: APIController?
    var apiKey :String = ""
    let kCellIdentifier: String = "commentCell"
    var commentsData = []
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
        
        newCommentTextView.delegate = self
        //        bodyTextView.textColor = UIColor.lightGrayColor()
        newCommentTextView.selectedTextRange = newCommentTextView.textRangeFromPosition(newCommentTextView.beginningOfDocument, toPosition: newCommentTextView.beginningOfDocument)
        newCommentTextView.textColor = UIColor.lightGrayColor()
        
        println("transmissionId = \(transmissionId)")
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        self.sideMenuController()?.sideMenu?.delegate = self
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
            api!.fetchComments(transmissionId, archivedValue: archived)
        }
        
        apiKey = api!.apiKey
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        if self.view.window != nil {
            if newCommentTextView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = newCommentTextView.textRangeFromPosition(newCommentTextView.beginningOfDocument, toPosition: newCommentTextView.beginningOfDocument)
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: NSString = newCommentTextView.text
        let updatedText: NSString = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.length == 0 {
            
            newCommentTextView.text = "Enter your comment"
            newCommentTextView.textColor = UIColor.lightGrayColor()
            
            newCommentTextView.selectedTextRange = newCommentTextView.textRangeFromPosition(newCommentTextView.beginningOfDocument, toPosition: newCommentTextView.beginningOfDocument)
            
        }
        else if newCommentTextView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            newCommentTextView.text = nil
            newCommentTextView.textColor = UIColor.blackColor()
        }
        
        return true
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
    
    @IBAction func abusiveButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/comments/report_abuse_of_comment.json?api_key=\(apiKey)&comment_id=\(sender.tag)"
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
                if jsonResult?.valueForKey("message") != nil {
                    var message :NSString? = jsonResult?.valueForKey("message") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Thank you,Admin have been notified", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.api!.fetchComments(self.transmissionId,archivedValue: self.archived)
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
                    var errorMessage: String = (jsonResult["error"] as String)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
                        }
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
    
    
    @IBAction func addNewCommentButtonClicked(sender: AnyObject) {
        
        if self.newCommentTextView.textColor == UIColor.lightGrayColor() {
            var alertController = UIAlertController(title: "", message: "Please enter the comment.", preferredStyle: UIAlertControllerStyle.Alert)
            //                        //Creating actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else {
            
        if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false

        var commentText = self.newCommentTextView.text
        println("=======commentText========\(commentText)")
        
        var body = join("+", self.newCommentTextView.text.componentsSeparatedByString(" "))
        var url : String = "http://\(GlobalVariable.apiUrl)/api/comments/add_comment.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&body=\(body)"
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
                var commentId :NSString? = jsonResult?.valueForKey("comment_id") as? NSString
                if jsonResult?.valueForKey("comment_id") != nil {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Your comment has been successfully added", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.api!.fetchComments(self.transmissionId,archivedValue: self.archived)
                            }
                            
                            self.newCommentTextView.text = ""
                            
                            self.newCommentTextView.text = "Enter your comment"
                            self.newCommentTextView.textColor = UIColor.lightGrayColor()
                            
                            self.newCommentTextView.selectedTextRange = self.newCommentTextView.textRangeFromPosition(self.newCommentTextView.beginningOfDocument, toPosition: self.newCommentTextView.beginningOfDocument)
                            
                            
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
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                    
                    //                    var errorMessage: NSDictionary = (jsonResult["validations"] as NSDictionary)
                    //                    dispatch_async(dispatch_get_main_queue()) {
                    //                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                    //                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                    //                        self.presentViewController(alertController, animated: true, completion: nil)
                    //                    }
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
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("commentsdata count = \(commentsData.count)")
        return commentsData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell: CommentsTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as CommentsTableViewCell
        let rowData: NSDictionary = self.commentsData[indexPath.row] as NSDictionary
        
        cell.abusiveButton.tag = rowData["id"] as Int
        
        cell.fromUserLabel.text = rowData["from_username"] as? String
        cell.timeLabel.text = rowData["comment_date"] as? String
        cell.bodyLabel?.text = rowData["body"] as? String
        
        let urlString: NSString = rowData["from_userimage"] as NSString
        //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
        
        let imgURL: NSURL? = NSURL(string: urlString)
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
        
        if results.objectForKey("comments") != nil {
            var resultsArr: NSArray = results["comments"] as NSArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                self.commentsData = resultsArr
                self.commentsTableView!.reloadData()
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                
            })
        }
        else {
            if results.objectForKey("error") != nil {
                var error: NSString = results["error"] as NSString
                let alertController = UIAlertController(title: "", message: "Comments not found.", preferredStyle: UIAlertControllerStyle.Alert)
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
