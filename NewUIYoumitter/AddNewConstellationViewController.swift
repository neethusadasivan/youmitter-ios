//
//  AddNewConstellationViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 08/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class AddNewConstellationViewController: UIViewController, APIControllerProtocol, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var constellationImageView: UIImageView!
    @IBOutlet var constellationNameText: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    
    var api: APIController?
    var apiKey :String = ""
    var x: CGFloat = 0
    let imagePicker = UIImagePickerController()
    var chosenImage: UIImage? = UIImage()
    var alertNotification = NotificationCount()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        imagePicker.delegate = self
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
        self.constellationImageView.addGestureRecognizer(tapGestureRecognizer)
        self.constellationImageView.userInteractionEnabled = true
        
        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.lightGrayColor()
        descriptionTextView.selectedTextRange = descriptionTextView.textRangeFromPosition(descriptionTextView.beginningOfDocument, toPosition: descriptionTextView.beginningOfDocument)
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func imageTapped(img: AnyObject)
    {
        var alertController = UIAlertController(title: "", message: "Select an option", preferredStyle: UIAlertControllerStyle.Alert)
        var cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.imagePicker.allowsEditing = false
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.imagePicker.cameraCaptureMode = .Photo
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
                
            } else {
                self.noCamera()
            }
            
        }
        alertController.addAction(cameraAction)
        var galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            
            self.imagePicker.allowsEditing = false //2
            self.imagePicker.sourceType = .PhotoLibrary //3
//            self.imagePicker.modalPresentationStyle = .Popover
            self.presentViewController(self.imagePicker, animated: true, completion: nil)//4
            //        imagePicker.popoverPresentationController?.barButtonItem = sender as UIBarButtonItem
            
            
        }
        alertController.addAction(galleryAction)
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage //2
        constellationImageView.contentMode = .ScaleAspectFit //3
        constellationImageView.image = chosenImage //4
        
        //        self.transmissionImageView.hidden = false
        //        self.rotateButton.hidden = false
        //        self.imageCancelButton.hidden = false
        
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        if self.view.window != nil {
            if descriptionTextView.textColor == UIColor.lightGrayColor() {
                descriptionTextView.selectedTextRange = descriptionTextView.textRangeFromPosition(descriptionTextView.beginningOfDocument, toPosition: descriptionTextView.beginningOfDocument)
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        let currentText: NSString = descriptionTextView.text
        let updatedText: NSString = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
        if updatedText.length == 0 {
            
            descriptionTextView.text = "Say what's on your mind, its completely anonymous, and it's free."
            descriptionTextView.textColor = UIColor.lightGrayColor()
            
            descriptionTextView.selectedTextRange = descriptionTextView.textRangeFromPosition(descriptionTextView.beginningOfDocument, toPosition: descriptionTextView.beginningOfDocument)
            
        }
        else if descriptionTextView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.blackColor()
        }
                
        return true
    }
    
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
//        Globals.APP_BASE_URL
//            + "api/constellations/add_constellation.json?api_key=" + Globals.apiKey
//            + "&name=" + userName.getText().toString() + ""
//            + "&description=" + firstName.getText().toString() +"&rotation_angleconst_img_rotate_angle="+rotation_angle
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var constellationName = join(" ", constellationNameText.text.componentsSeparatedByString(" "))
        
        var description = ""
        if descriptionTextView.textColor == UIColor.blackColor() {
            description = join(" ", descriptionTextView.text.componentsSeparatedByString(" "))
        }
        
        if constellationName == "" {
            var alertController = UIAlertController(title: "", message: "Constellation name or description can't be blank.", preferredStyle: UIAlertControllerStyle.Alert)
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
            
            //        request.HTTPMethod = "POST"
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
            
            
            var url = "http://\(GlobalVariable.apiUrl)/api/constellations/add_constellation.json?"
            var request = NSMutableURLRequest(URL: NSURL(string: url)!)
            var session = NSURLSession.sharedSession()
            request.HTTPMethod = "POST"
            
            //        var testImage = UIImage(named: "logo.png") as UIImage?
            var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
            //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
            
            var base64String = ""
            
            var params = ["api_key":apiKey, "name":constellationName, "description":description,  "rotation_angleconst_img_rotate_angle":"\(self.x)"] as Dictionary
            if imageData != nil {
                base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
                params = ["image": base64String, "api_key":apiKey, "name":constellationName, "description":description,  "rotation_angleconst_img_rotate_angle":"\(self.x)"] as Dictionary
            }

            println("=======base64string \(base64String) base64string=======")
            var err: NSError?
            let boundary = generateBoundaryString()
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = createBodyWithParameters(params, filePathKey: "file", boundary: boundary)
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            
            
            var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
                println("Response: \(response)")
                var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
                
                var err: NSError?
                var json: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
                
                //            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
                
                var msg = "No message"
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(err != nil) {
                    //                println(err!.localizedDescription)
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: '\(jsonStr)'")
                    
                }
                else {
                    
                    println("====== \(json) ======")
                    
                    if (json != nil) {
                        var constellation :NSString? = json?.valueForKey("constellation") as? NSString
                        if json?.valueForKey("constellation") != nil {
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                var alertController = UIAlertController(title: "", message: "Constellation \(constellation!)", preferredStyle: UIAlertControllerStyle.Alert)
                                //                        //Creating actions
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    println("Ok Pressed")
                                    //
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                    
                                    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                    appDelegate.homeButtonClicked()
                                    
                                }
                                //                        //Creating actions
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                                //
                                //                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                            }
                            
                        }
                            
                        else {
                            println("======== else part ========")
                            if json?.valueForKey("constellation") != nil {
                                var errorMessage: NSDictionary = (json["validations"] as NSDictionary)
                                let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                    UIAlertAction in
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                }
                                alertController.addAction(okAction)
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                            else {
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.activityIndicatorView.stopAnimating()
                                    self.activityIndicatorView.hidden = true
                                    self.view.userInteractionEnabled = true
                                }
                            }
                        }
                        
                    }
                    else {
                        println(" === nil ==== ")
                        // couldn't load JSON, look at error
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                    }
                    
                    return
                    
                }
                })
            task.resume()
            }
        }
        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, boundary: String) -> NSData {
        let body = NSMutableData()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        //        if paths != nil {
        //            for path in paths! {
        //                let filename = path.lastPathComponent
        //                let data = NSData(contentsOfFile: path)
        //                let mimetype = "image/jpg"
        //
        //                body.appendString("--\(boundary)\r\n")
        //                body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        //                body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        //                body.appendData(data!)
        //                body.appendString("\r\n")
        //            }
        //        }
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: {})
        
    }
    
    @IBAction func rotateButtonClicked(sender: AnyObject) {
        
        println("======= x = \(x)")
        x = x + 90
        if x >= 360 {
            self.x = 0
        }
        UIView.animateWithDuration(2.0, animations: {
            self.constellationImageView.transform = CGAffineTransformMakeRotation((self.x * CGFloat(M_PI)) / 180.0)
        })

        
    }
    
//    @IBAction func cancelButtonClicked(sender: AnyObject) {
//        
//    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
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
