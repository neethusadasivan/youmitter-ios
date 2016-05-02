//
//  TransmissionDetailsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 26/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class TransmissionDetailsViewController: UIViewController, APIControllerProtocol, UITextFieldDelegate, UITextViewDelegate {

    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var categoryNameLabel: UILabel!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var transmissionImageView: UIImageView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var heightForTransmissionImage: NSLayoutConstraint!
    @IBOutlet var tunedInImageButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var commentTextField: UITextField!
    
    @IBOutlet var affirmImageView: UIImageView!
    @IBOutlet var tuneInNickNameField: UITextField!
    @IBOutlet var grantMessageField: UITextField!
    @IBOutlet var directMessageField: UITextField!
    @IBOutlet var directTextView: UITextView!
    
    var api: APIController?
    var apiKey :String = ""
    var shareMedia: String = ""
    var transmissionDetails :NSDictionary!
    var categoryImage :String = "", categoryName :String = "", fromName :String = "", toName :String = "", body :String = "", transmissionImage :String = "", location :String = "", time :String = ""
    var transmissionId: Int = 0
    var categoryId: Int = 0
    var toUserId: Int = 0
    var isTunedUser: String = ""
    var tuneTitle: String = ""
    var archived: String = "false"
    
    func initializeData() {
        self.transmissionId = transmissionDetails["id"] as Int

        if transmissionDetails["from_user_id"] as? Int != nil {
            self.toUserId = transmissionDetails["from_user_id"] as Int
        }
        else {
            println("=====else nil \(self.toUserId)=====")
        }
        
        if transmissionDetails?.valueForKey("archived") != nil {
            archived = transmissionDetails["archived"] as String
        }
        
        toName = transmissionDetails["to_username"] as              String
        
        if archived == "true" {
            toLabel.text = transmissionDetails["to_username"] as? String
        }
        else {
            fromLabel.text = transmissionDetails["from_username"] as? String
            var transmissionConstellationsCountString: String? = transmissionDetails["transmission_constellations_count"] as? String
            var transmissionConstellationsCountInt = transmissionConstellationsCountString!.toInt()
            if transmissionConstellationsCountInt == nil {
                toLabel.text = transmissionDetails["to_username"] as? String
            }
            else if transmissionConstellationsCountInt > 1 {
            
                println("greater than zero")
                toLabel.text = "\(transmissionConstellationsCountInt!) Constellations"
                var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("constellationCountTapped:"))
                self.toLabel.addGestureRecognizer(tapGestureRecognizer)
            
            }
            else {
                println("not greater than zero")
                toLabel.text = transmissionDetails["to_username"] as? String
            
            }
        }
        
        
        
        bodyLabel.text = transmissionDetails["body"] as? String
        categoryNameLabel.text = transmissionDetails["category_name"] as? String
        locationLabel.text = transmissionDetails["address"] as? String
        timeLabel.text = transmissionDetails["started_at"] as? String
        
        var commentCount = transmissionDetails["comment_count"] as? Int
        if commentCount != 0 {
            commentButton.setTitle(" Comment(\(commentCount!))", forState: UIControlState.Normal)
        }
        else {
            commentButton.setTitle(" Comment(0)", forState: UIControlState.Normal)
        }
        
//        categoryId = transmissionDetails["category_id"] as Int
//        println("categoory id = \(categoryId)")
//        var categoryImageString = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(categoryId).png"
//        let imgURL: NSURL = NSURL(string: categoryImageString)!
//        let imgData = NSData(contentsOfURL: imgURL)
//        categoryImageView.image = UIImage(data :imgData!)
        
        let urlString: NSDictionary? = (transmissionDetails["photo"]?["photo"] as? NSDictionary)
        if (urlString != nil) {
            
//            dispatch_async(dispatch_get_main_queue()) {
//                let urlForImage:NSString = urlString?.valueForKey("url") as NSString
//                let transImgURL: NSURL = NSURL(string: urlForImage)!
//                let transImgData = NSData(contentsOfURL: transImgURL)
//                if transImgData != nil {
//                    self.transmissionImageView.image = UIImage(data :transImgData!)
//                }
//            }
            
            let urlForImage:NSString = urlString?.valueForKey("url") as NSString
            let transImgURL: NSURL = NSURL(string: urlForImage)!
            let request: NSURLRequest = NSURLRequest(URL: transImgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    var transImageData = UIImage(data: data)
                    
                    // Store the image in to our cache
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.transmissionImageView.image = transImageData
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            transmissionImageView.hidden = true
            heightForTransmissionImage.constant = 0.0
        }
        
    }
    
    func constellationCountTapped(img: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "\(self.toName)", preferredStyle: UIAlertControllerStyle.Alert)
        //Creating actions
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            println("Ok Pressed")
            
        }
        //Creating actions
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func locationTapped(location: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "\(locationLabel.text!)", preferredStyle: UIAlertControllerStyle.Alert)
        //Creating actions
        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            println("Ok Pressed")
            
        }
        //Creating actions
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    func imageTap(sender: AnyObject) {
        let imageView = sender.view as UIImageView
        let newImageView = UIImageView(image: transmissionImageView.image)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "dismissFullscreenImage:")
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.hidesBarsOnTap = true
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
        self.navigationController?.hidesBarsOnTap = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transmissionImageView.contentMode = UIViewContentMode.ScaleAspectFill
        transmissionImageView.clipsToBounds = true
        
        transmissionImageView.userInteractionEnabled = true
        transmissionImageView.multipleTouchEnabled = true
        var tapgesture = UITapGestureRecognizer(target: self, action: Selector("imageTap:"))
        tapgesture.numberOfTapsRequired = 1
        transmissionImageView.addGestureRecognizer(tapgesture)
        
        self.tabBarController?.tabBar.hidden = true
        
        //Looks for single or multiple taps.
        
        var affirmTap = UITapGestureRecognizer(target:self, action:Selector("affirmButtonClicked:"))
//        cell.affirmImageView.tag = rowData["id"] as Int
        self.affirmImageView.addGestureRecognizer(affirmTap)
        self.affirmImageView.userInteractionEnabled = true
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("locationTapped:"))
        self.locationLabel.addGestureRecognizer(tapGestureRecognizer)
        
        commentTextField.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.automaticallyAdjustsScrollViewInsets = false
        println("====== TransmissionDetailsViewController ======")
        println("TransmissionDetails = \(self.transmissionDetails)")
        initializeData()
        
        activityIndicatorView.stopAnimating()
        activityIndicatorView.hidden = true
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        shareMedia = api!.shareMedia
        
        isTunedUser = transmissionDetails["is_tuned_user"] as String
        if isTunedUser == "no" {
            tuneTitle = "Tune In"
        }
        else {
            tuneTitle = "Tune Out"
        }
    }
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        
        if (textField == commentTextField) {
            if (heightForTransmissionImage.constant == 0.0) {
                self.scrollView.setContentOffset(CGPointMake(0, 200), animated: true)
                self .viewDidLayoutSubviews()
            }
            else {
                self.scrollView.setContentOffset(CGPointMake(0, 400), animated: true)
                self .viewDidLayoutSubviews()
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if (textField == commentTextField){
            self.scrollView .setContentOffset(CGPointMake(0, 0), animated: true)
            self .viewDidLayoutSubviews()
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        categoryId = transmissionDetails["category_id"] as Int
        println("categoory id = \(categoryId)")
        var categoryImageString = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(categoryId).png"
        let imgURL: NSURL = NSURL(string: categoryImageString)!
//        let imgData = NSData(contentsOfURL: imgURL)
//        if imgData != nil {
//            categoryImageView.image = UIImage(data :imgData!)
//        }
//        
//        var transImgURL: NSURL = NSURL(string: urlForImage)!
//        
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var categoryImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                   
                    self.categoryImageView.image = categoryImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
    }
    
    @IBAction func affirmButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/affirm.json?api_key=\(apiKey)&transmission_id=\(transmissionId)"
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
                        var alertController = UIAlertController(title: "", message: "Transmission has been affirmed", preferredStyle: UIAlertControllerStyle.Alert)
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
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["affirm"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toComments1" {
            
            var commentsController: CommentsViewController = segue.destinationViewController as CommentsViewController
            commentsController.transmissionId = self.transmissionId
            commentsController.archived = self.archived
            commentsController.hidesBottomBarWhenPushed = true
        }
        
    }
    
    @IBAction func commentButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var body = join("+", commentTextField.text.componentsSeparatedByString(" "))
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
                        var alertController = UIAlertController(title: "", message: "Comment Added successfully", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchComments(self.transmissionId)
                            self.commentTextField.text = ""
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
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
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        if shareMedia == "on" {
            let textToShare = "Universe is listening"
            
            if let myWebsite = NSURL(string: "http://\(GlobalVariable.apiUrl).com/")
            {
                let objectsToShare = [textToShare, myWebsite]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
        else {
            let alertController: UIAlertController = UIAlertController(title: "Please change the app settings to enable share", message: "", preferredStyle: .Alert)
            
            //CANCEL ACTION START
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
            
        }
        
    }
    
    @IBAction func tunedInImageButtonClicked(sender: AnyObject) {
        
        if (self.toUserId != 0) {
        
        let alertController: UIAlertController = UIAlertController(title: "Select an action", message: "", preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        alertController.addAction(cancelAction)
        //CANCEL ACTION END
        
        //TUNE IN ACTION START
        let tuneIn: UIAlertAction = UIAlertAction(title: "\(self.tuneTitle)", style: .Default) { action -> Void in
            //Code for tuned in
            if self.tuneTitle == "Tune In" {
                
                let tunedInController: UIAlertController = UIAlertController(title: "Enter nickname", message: "", preferredStyle: .Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                tunedInController.addAction(cancelAction)
                //Create and an option action
                var tuneInNickName = ""
                let doneAction: UIAlertAction = UIAlertAction(title: "Done", style: .Default) { action -> Void in
                    //Do some other stuff
                    tuneInNickName = join("%20", self.tuneInNickNameField.text.componentsSeparatedByString(" "))
                    if tuneInNickName == "" {
                        
                        var errorAlertController = UIAlertController(title: "", message: "Please provide a nickname for tuning.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                        }
                        //Creating actions
                        errorAlertController.addAction(okAction)
                        self.presentViewController(errorAlertController, animated: true, completion: nil)
                    }
                    else {
                        self.tuneInUser(tuneInNickName)
                        println("tuneInNickName = \(tuneInNickName)")
                    }
                }
                tunedInController.addAction(doneAction)
                //Add a text field
                tunedInController.addTextFieldWithConfigurationHandler { textField -> Void in
                    //TextField configuration
                    textField.textColor = UIColor.blueColor()
                    self.tuneInNickNameField = textField
                }
                
                //Present the AlertController
                self.presentViewController(tunedInController, animated: true, completion: nil)
                
            }
            else if self.tuneTitle == "Tune Out" {
                let tunedOutController: UIAlertController = UIAlertController(title: "Click confirm to tune out.", message: "", preferredStyle: .Alert)
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                tunedOutController.addAction(cancelAction)
                
                let confirmAction: UIAlertAction = UIAlertAction(title: "Confirm", style: .Default) { action -> Void in
                    //Do some stuff
                    self.tuneOutUser()
                }
                tunedOutController.addAction(confirmAction)
                
                self.presentViewController(tunedOutController, animated: true, completion: nil)
            }
            
        }
        alertController.addAction(tuneIn)
        //TUNE IN ACTION END
        
        
        //SEND GRANT MESSAGE START
        if categoryId == 1 {
            let sendGrantMessage: UIAlertAction = UIAlertAction(title: "Grant", style: .Default) { action -> Void in
                println("====  send direct message in =====")
                
                let sendGrantMessageController: UIAlertController = UIAlertController(title: "Enter message", message: "", preferredStyle: .Alert)
                
                //Create and add the Cancel action
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
                    //Do some stuff
                }
                sendGrantMessageController.addAction(cancelAction)
                //Create and an option action
                var grantMessage = ""
                let sendAction: UIAlertAction = UIAlertAction(title: "Send", style: .Default) { action -> Void in
                    //Do some other stuff
                    grantMessage = join("+", self.grantMessageField.text.componentsSeparatedByString(" "))
                    self.sendGrantMessage(grantMessage)
                }
                sendGrantMessageController.addAction(sendAction)
                //Add a text field
                sendGrantMessageController.addTextFieldWithConfigurationHandler { textField -> Void in
                    //TextField configuration
                    textField.textColor = UIColor.blueColor()
                    self.grantMessageField = textField
                    
                }
                
                //Present the AlertController
                self.presentViewController(sendGrantMessageController, animated: true, completion: nil)
                
            }
            
            alertController.addAction(sendGrantMessage)
        }
        //SEND GRANT MESSAGE END
        
        
        //SEND DIRECT MESSAGE START
        let sendDirectMessage: UIAlertAction = UIAlertAction(title: "Send Direct Message", style: .Default) { action -> Void in
            println("====  send direct message in =====")
            
            var message = "Enter message\n\n\n\n\n\n\n\n\n\n"
            let sendDirectMessageController: UIAlertController = UIAlertController(title: "\(message)", message: "", preferredStyle: .Alert)
            
//            //Create and add the Cancel action
//            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
//                //Do some stuff
//            }
//            sendDirectMessageController.addAction(cancelAction)
//            //Create and an option action
//            var directMessage = ""
//            let sendAction: UIAlertAction = UIAlertAction(title: "Send", style: .Default) { action -> Void in
//                //Do some other stuff
//                directMessage = join("+", self.directMessageField.text.componentsSeparatedByString(" "))
//                self.sendDirectMessage(directMessage)
//            }
//            sendDirectMessageController.addAction(sendAction)
//            
            
            
            var textViewFrame: CGRect = CGRectMake(17, 52, 233, 100)
            self.directTextView = UITextView(frame: textViewFrame)
            self.directTextView.userInteractionEnabled = true
            self.directTextView.delegate = self
            
            sendDirectMessageController.view.addSubview(self.directTextView)
            
            var toolFrame = CGRectMake(17, 185, 233, 45);
            var toolView: UIView = UIView(frame: toolFrame);
//            toolView.backgroundColor = UIColor.redColor()
            var buttonCancelFrame: CGRect = CGRectMake(1, 7, 100, 30); //size & position of the button as placed on the toolView
            //Create the cancel button & set its title
            var buttonCancel: UIButton = UIButton(frame: buttonCancelFrame);
            buttonCancel.setTitle("Cancel", forState: UIControlState.Normal);
            buttonCancel.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal);
//            buttonCancel.backgroundColor = UIColor.greenColor()
            
            toolView.addSubview(buttonCancel);
            buttonCancel.addTarget(self, action: "cancelSelection:", forControlEvents: UIControlEvents.TouchDown);
            //add buttons to the view
            var buttonOkFrame: CGRect = CGRectMake(150, 7, 80, 30); //size & position of the button as placed on the toolView
            //Create the Select button & set the title
            var buttonOk: UIButton = UIButton(frame: buttonOkFrame);
            buttonOk.setTitle("Send", forState: UIControlState.Normal);
            buttonOk.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal);
//            buttonOk.backgroundColor = UIColor.greenColor()
            
            toolView.addSubview(buttonOk)
            buttonOk.addTarget(self, action: "saveProfile:", forControlEvents: UIControlEvents.TouchDown);
            sendDirectMessageController.view.addSubview(toolView);
            
//            //Add a text field
//            sendDirectMessageController.addTextFieldWithConfigurationHandler { textField -> Void in
//                //TextField configuration
//                textField.textColor = UIColor.blueColor()
//                self.directMessageField = textField
//                
//            }
//            //Add a text field
//            
            
            
            //Present the AlertController
            self.presentViewController(sendDirectMessageController, animated: true, completion: nil)
            
            
            
        }
        alertController.addAction(sendDirectMessage)
        //SEND DIRECT MESSAGE END
        
        //REPORT ABUSE START
        let reportAbuse: UIAlertAction = UIAlertAction(title: "Report Abuse", style: .Default) { action -> Void in
            println("==== report abuse =====")
            
            self.reportAbuseTransmission()
            println("report abuse completed")
            
        }
        alertController.addAction(reportAbuse)
        //REPORT ABUSE END
        
        //We need to provide a popover sourceView when using it on iPad
        //        actionSheetController.popoverPresentationController?.sourceView = sender as UIView;
        
        //Present the AlertController
        self.presentViewController(alertController, animated: true, completion: nil)
        
        }
        else {
            let alertController: UIAlertController = UIAlertController(title: "This person is not yet a member and can't receive direct messages.", message: "", preferredStyle: .Alert)
            
            //CANCEL ACTION START
            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                //Just dismiss the action sheet
            }
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func saveProfile(sender: UIButton){
        // Your code when select button is tapped
        println("send button clicked")
        var directMessage = ""
        var message = join(" ", self.directTextView.text.componentsSeparatedByString("\n"))
        directMessage = join("+", message.componentsSeparatedByString(" "))
        println("direct message ==== \(directMessage)")
        self.dismissViewControllerAnimated(true, completion: nil)
        self.sendDirectMessage(directMessage)

    }
    
    func cancelSelection(sender: UIButton){
        println("Cancel");
        self.dismissViewControllerAnimated(true, completion: nil);
        // We dismiss the alert. Here you can add your additional code to execute when cancel is pressed
    }
    
    
    func tuneOutUser() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/tune_out_user.json?api_key=\(apiKey)&transmission_id=\(self.transmissionId)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if jsonResult?.valueForKey("notification_title") != nil {
                    var responseMessage: String = jsonResult["notification_title"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(responseMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                            appDelegate.fromConstellationToUniverseController(self.transmissionId)
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        //self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    self.tuneTitle = "Tune In"
                    //
                }
                else if jsonResult?.valueForKey("validation_error") != nil {
                    
                    var validation: NSDictionary = jsonResult["validation_error"] as NSDictionary
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(validation)", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
                else if jsonResult?.valueForKey("error") != nil {
                    
                    var error: String = jsonResult["error"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
                
                
            } else {
                println(" === nil ==== ")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        })
            
        }
        
    }
    
    func tuneInUser(nickName: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/tune_in_user.json?api_key=\(apiKey)&transmission_id=\(self.transmissionId)&nickname=\(nickName)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if jsonResult?.valueForKey("notification_title") != nil {
                    var responseMessage: String = jsonResult["notification_title"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(responseMessage)", preferredStyle: UIAlertControllerStyle.Alert)
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
                        
                        //self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    self.tuneTitle = "Tune Out"
                    //
                }
                else if jsonResult?.valueForKey("validation_error") != nil {
                    
                    var validation: String = jsonResult["validation_error"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(validation)", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
                else if jsonResult?.valueForKey("error") != nil {
                    
                    var error: String = jsonResult["error"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
                
                
            } else {
                println(" === nil ==== ")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        })
            
        }
    }
    
    func sendGrantMessage(message: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/grant_direct_message.json?api_key=\(apiKey)&to_user_id=\(self.toUserId)&transmission_id=\(self.transmissionId)&message=\(message)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if jsonResult?.valueForKey("conversation_id") != nil {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Message granted successfully.", preferredStyle: UIAlertControllerStyle.Alert)
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
                        
                        //self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    //
                }
                else if jsonResult?.valueForKey("validations") != nil {
                    
                    var validations: NSDictionary = jsonResult["validations"] as NSDictionary
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Recipient cannot be yourself", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
            } else {
                println(" === nil ==== ")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            
        })
            
        }
    }
    
    func sendDirectMessage(message: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/conversations/grant_direct_message.json?api_key=\(apiKey)&to_user_id=\(self.toUserId)&message=\(message)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        println("url == \(url)")
        request.URL = NSURL(string: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if jsonResult?.valueForKey("conversation_id") != nil {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Message sent successfully.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
//                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        //self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    //
                }
                else if jsonResult?.valueForKey("validations") != nil {
                    
                    var validations: NSDictionary = jsonResult["validations"] as NSDictionary
                    var message: String = validations["1"] as String
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
//                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                }
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
                
//                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            
        })
            
        }
    }
    
    func reportAbuseTransmission() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/transmission_report_abuse.json?api_key=\(apiKey)&transmission_id=\(self.transmissionId)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            println("==== jsonResult === \(jsonResult) =======")
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if jsonResult?.valueForKey("report_abuse") != nil {
                    var message :NSString? = jsonResult?.valueForKey("report_abuse") as? NSString
                    var responseMessage: String = ""
                    if message == "success" {
                        responseMessage = "Thank you,Admin have been notified."
                    }
                    else if message == "Failed" {
                        responseMessage = "Something went wrong."
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(responseMessage)", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                }
                else {
                    println("======== else part ========")
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                    
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
