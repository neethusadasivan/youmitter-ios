//
//  MyConstellationsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 02/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MyConstellationsViewController: UIViewController, APIControllerProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var constellationNameText: UITextField!
    @IBOutlet var constellationImageView: UIImageView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var muteButton: UIButton!
    
    var api: APIController?
    var apiKey :String = ""
    var constellationDetails: NSDictionary!
    var constellationId: Int?
    var constellationName: String?
    var constellationImageString: String?
    var statusOfConstellation: String?
    var x:CGFloat = 0
    let imagePicker = UIImagePickerController()
    var chosenImage: UIImage? = UIImage()
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            println("inside reveal view controller")
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
        
        imagePicker.delegate = self
        
        if let constellationIdIsNotNill = defaults.objectForKey("selectedConstellatonId") as? Int {
            self.constellationId = defaults.objectForKey("selectedConstellatonId") as? Int
        }
        if let constellationNameIsNotNill = defaults.objectForKey("selectedConstellatonName") as? String {
            self.constellationName = defaults.objectForKey("selectedConstellatonName") as? String
        }
        
        println("=========constellationId=========\(self.constellationId)")
        self.constellationNameText.text = self.constellationName
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            api!.fetchThisConstellation(self.constellationId!)
        }
        
//        self.constellationId = self.constellationDetails["id"] as? Int
        
//        self.constellationNameText.text = self.constellationDetails["name"] as NSString
//        
//        let urlForImage:NSString = self.constellationDetails["image"] as NSString
//        let consImgURL: NSURL = NSURL(string: urlForImage)!
//        let request: NSURLRequest = NSURLRequest(URL: consImgURL)
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//            if error == nil {
//                var consImageData = UIImage(data: data)
//                
//                // Store the image in to our cache
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    self.constellationImageView.image = consImageData
//                })
//            }
//            else {
//                println("Error: \(error.localizedDescription)")
//            }
//        })

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toSeeActivity" {
            var seeActivityViewController: SeeActivityViewController = segue.destinationViewController as SeeActivityViewController
            //            var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
            
            seeActivityViewController.constellationId = self.constellationId as Int!
        }
        else if segue.identifier == "toViewRequest" {
            
            var constellationViewController: ViewRequestViewController = segue.destinationViewController as ViewRequestViewController
            //                        var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
            
            constellationViewController.constellationId = self.constellationId!
            
        }
        else if segue.identifier == "toSendMessage" {
            
            var sendMessageViewController: SendMessageViewController = segue.destinationViewController as SendMessageViewController
            //                        var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
            
            sendMessageViewController.constellationId = self.constellationId!
            sendMessageViewController.constellationName = self.constellationName!
            sendMessageViewController.constellationImageString = self.constellationImageString!
            
        }
        else if segue.identifier == "toConstellationMembers" {
            
            var constellationViewController: ConstellationMembersViewController = segue.destinationViewController as ConstellationMembersViewController
            //                        var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
            
            constellationViewController.constellationId = self.constellationId!
            
        }
        else if segue.identifier == "toViewTransmissions" {
           defaults.setObject("1", forKey: "tuneInTransmissionFlag")
        }
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        println("results === \(results)")
        
        let urlForImage:NSString = results["image"] as NSString
        self.constellationImageString = urlForImage
        self.statusOfConstellation = results["status"] as NSString
        
        println("======urlForImage=======\(self.constellationImageString!)")
        if self.statusOfConstellation == "active" {
            self.muteButton.setTitle(" Mute", forState: UIControlState.Normal)
//            self.muteButton.setImage(UIImage(named: ""), forState: .Normal)
        }
        else {
            self.muteButton.setTitle(" Unmute", forState: UIControlState.Normal)
        }
        
        let consImgURL: NSURL = NSURL(string: self.constellationImageString!)!
        println("=====consImgURL====\(consImgURL)=====")
        let request: NSURLRequest = NSURLRequest(URL: consImgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var consImageData = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.constellationImageView.image = consImageData
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
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
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        
//        Globals.APP_BASE_URL
//            + "api/constellations/delete_constellation.json?api_key="+ Globals.apiKey
//                + "" + "&constellation_id=" + const_id;
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellations/delete_constellation.json?api_key=\(apiKey)&constellation_id=\(self.constellationId)"
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
                if jsonResult?.valueForKey("constellation") != nil {
                    var message :NSString? = jsonResult?.valueForKey("constellation") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Constellation deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                            appDelegate.homeButtonClicked()
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
            
                }
                else {
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Constellation not found to delete.", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
    
    @IBAction func editButtonClicked(sender: AnyObject) {
        
        var title = sender.titleForState(.Normal)
        if title == " Edit" {

            println("edit button clicked")
            self.editButton.setTitle(" Update", forState: UIControlState.Normal)
            self.editButton.setImage(UIImage(named: ""), forState: .Normal)
            self.rotateButton.hidden = false
            var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("imageTapped:"))
            self.constellationImageView.addGestureRecognizer(tapGestureRecognizer)
            self.constellationImageView.userInteractionEnabled = true
            self.constellationNameText.enabled = true
            
        }
        else if title == " Update" {
            
            println("update button clicked")
            updateConstellation()
//            self.editButton.setTitle("Update", forState: UIControlState.Normal)
            
        }
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
//                self.imagePicker.popoverPresentationController?.sourceView = self.view
                //            alertController.popoverPresentationController?.sourceRect = self.relationshipButton.bounds
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
//            self.imagePicker.popoverPresentationController?.sourceView = self.view
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
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device does not have a camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
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
        
        body.appendString("--\(boundary)--\r\n")
        return body
    }
    
    
    func updateConstellation() {
        
        //         Globals.APP_BASE_URL
        //        + "api/constellations/edit_constellation.json?api_key=" + Globals.apiKey
        //            + "&constellation_id=" + Globals.constId+ ""+"&const_img_rotate_angle="+rotation_angle
        //                + "&name=" + EditName.getText().toString()  +”"
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var url = "http://\(GlobalVariable.apiUrl)/api/constellations/edit_constellation.json?"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        //        var testImage = UIImage(named: "logo.png") as UIImage?
        var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
        //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
        
        var base64String = ""
        
        var params = ["api_key":apiKey, "constellation_id":"\(self.constellationId!)", "const_img_rotate_angle":"\(self.x)", "name":"\(self.constellationNameText.text)"] as Dictionary
        if imageData != nil {
            base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            params = ["new_image":base64String, "api_key":apiKey, "constellation_id":"\(self.constellationId!)", "const_img_rotate_angle":"\(self.x)", "name":"\(self.constellationNameText.text)"] as Dictionary
        }

        println("=======base64string \(base64String) base64string=======")
        //        var params = ["photo": base64String, "api_key":apiKey, "from_username":fromUserName, "category_id":selectedCategoryId, "preset_duration_id":selectedDurationId, "body":bodyContent, "to_username":toUserName] as Dictionary
        var err: NSError?
        //        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
            }
            else {
                
                println("====== json ==== \(json) ======")
                
                
                if (json != nil) {
                    if json?.valueForKey("update") != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Constellation updated successfully.", preferredStyle: UIAlertControllerStyle.Alert)
                            //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                //                            self.api!.fetchMessages("")
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                appDelegate.homeButtonClicked()
                                
                                
                            }
                            //Creating actions
                            alertController.addAction(okAction)
                            self.presentViewController(alertController, animated: true, completion: nil)
                            
                            ////                        self.performSegueWithIdentifier("universeView", sender: self)
                        }
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Constellation cannot be updated,something went wrong.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            }
        })
        //
        task.resume()
        
        }
        
    }
    
    @IBAction func muteButtonClicked(sender: AnyObject) {
        
//        Globals.APP_BASE_URL+ "api/constellations/mute_constellation.json?api_key="
//            + Globals.apiKey + "&constellation_id=" + id;
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var title = sender.titleForState(.Normal)
        var url : String = ""
        var messageToDisplay = ""
        var titleAfterClick = ""
        if title == " Mute" {
            url = "http://\(GlobalVariable.apiUrl)/api/constellations/mute_constellation.json?api_key=\(apiKey)&constellation_id=\(self.constellationId!)"
            messageToDisplay = "Constellation muted."
            titleAfterClick = " Unmute"
        }
        else if title == " Unmute" {
            url = "http://\(GlobalVariable.apiUrl)/api/constellations/unmute_constellation.json?api_key=\(apiKey)&constellation_id=\(self.constellationId!)"
            messageToDisplay = "Constellation unmuted."
            titleAfterClick = " Mute"
        }
        
//        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellations/mute_constellation.json?api_key=\(apiKey)&constellation_id=\(self.constellationId)"
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
                if jsonResult?.valueForKey("constellation") != nil {
                    var message :NSString? = jsonResult?.valueForKey("constellation") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "\(messageToDisplay)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            
                            self.muteButton.setTitle("\(titleAfterClick)", forState: UIControlState.Normal)
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
                        let alertController = UIAlertController(title: "", message: "Constellation not found to mute.", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
            }
            
        })
            
        }
        
    }
    
    @IBAction func viewTransmissionsButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.fromConstellationToUniverseController(self.constellationId!)
    }
    
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func messageButtonClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
//        unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func alertButtonClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
//        unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    
}
