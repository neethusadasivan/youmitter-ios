//
//  SendMessageViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 06/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SendMessageViewController: UIViewController, APIControllerProtocol, UITextViewDelegate {

    @IBOutlet var constellationNameText: UILabel!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageContentTextView: UITextView!
    @IBOutlet var constellationImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var api: APIController?
    var apiKey :String = ""
    var constellationId: Int?
    var constellationName: String?
    var constellationImageString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        println("constellation id = \(self.constellationId)")
        println("constellation name = \(self.constellationName)")
        println("constellation image string = \(self.constellationImageString)")
        
        constellationNameText.text = self.constellationName
        messageContentTextView.delegate = self
        messageContentTextView.textColor = UIColor.lightGrayColor()
        messageContentTextView.selectedTextRange = messageContentTextView.textRangeFromPosition(messageContentTextView.beginningOfDocument, toPosition: messageContentTextView.beginningOfDocument)
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        let imgURL: NSURL = NSURL(string: constellationImageString!)!
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
                var constellationImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.constellationImageView.image = constellationImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        if self.view.window != nil {
            if messageContentTextView.textColor == UIColor.lightGrayColor() {
                messageContentTextView.selectedTextRange = messageContentTextView.textRangeFromPosition(messageContentTextView.beginningOfDocument, toPosition: messageContentTextView.beginningOfDocument)
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: NSString = messageContentTextView.text
        let updatedText: NSString = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.length == 0 {
            
            messageContentTextView.text = "Say what's on your mind, its completely anonymous, and it's free."
            messageContentTextView.textColor = UIColor.lightGrayColor()
            
            messageContentTextView.selectedTextRange = messageContentTextView.textRangeFromPosition(messageContentTextView.beginningOfDocument, toPosition: messageContentTextView.beginningOfDocument)
            
        }
        else if messageContentTextView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            messageContentTextView.text = nil
            messageContentTextView.textColor = UIColor.blackColor()
        }
        
        
        return true
    }
    
    @IBAction func sendButtonClicked(sender: AnyObject) {
        
        if (messageContentTextView.textColor == UIColor.lightGrayColor()) {
            
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "", message: "Message can't be blank", preferredStyle: UIAlertControllerStyle.Alert)
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
        else {
            
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var messageBody = ""
        if messageContentTextView.text != "Say what's on your mind, its completely anonymous, and it's free." {
            messageBody = join("+", messageContentTextView.text.componentsSeparatedByString(" "))
        }
        if messageBody == "" {
            var alertController = UIAlertController(title: "", message: "Message body can't be blank.", preferredStyle: UIAlertControllerStyle.Alert)
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
        else {
        //        conversations/new_message.json?api_key="+Globals.apiKey+"&recipient_username="+userName+"&message="+messageBody
        
        if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellations/send_message.json?api_key=\(apiKey)&constellation_id=\(self.constellationId!)&message=\(messageBody)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        println("url === \(url)")
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
                var responseMessage :NSString? = jsonResult?.valueForKey("message") as? NSString
                if jsonResult?.valueForKey("message") != nil {
                    var message = jsonResult?.valueForKey("message") as? NSString
                    if message != "Failed" {
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Message sent successfully.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                            self.messageContentTextView.text = ""
//                            self.messageContentTextView.textColor = UIColor.lightGrayColor()
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                                
                                println("Ok Pressed")
                                
                                self.navigationController?.popViewControllerAnimated(true)
                            
                            }
                        //Creating actions
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Message sending failed.", preferredStyle: UIAlertControllerStyle.Alert)
                            //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                self.messageContentTextView.text = ""
                                //                            self.messageContentTextView.textColor = UIColor.lightGrayColor()
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
                    }
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("validations") != nil  {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["validations"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Message cannot be sent", preferredStyle: UIAlertControllerStyle.Alert)
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
                else {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
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
            
        }
            
        }
        
    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        
    }

}
