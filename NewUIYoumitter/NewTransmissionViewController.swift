//
//  NewTransmissionViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 25/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

//var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

class NewTransmissionViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, APIControllerProtocol, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var fromUserNameText: UITextField!
    @IBOutlet var toUserNameText: UITextField!
    @IBOutlet var bodyText: UITextField!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var constellationButton: UIButton!
    @IBOutlet var selectCategoryButton: UIButton!
    @IBOutlet var timeDurationButton: UIButton!
    @IBOutlet var categorySelectedImageView: UIImageView!
    @IBOutlet var categorySelectedText: UITextField!
    @IBOutlet var durationTextButton: UIButton!
    @IBOutlet var heghtConstraintForDurationButton: NSLayoutConstraint!
    @IBOutlet var heightConstraintForCategoryText: NSLayoutConstraint!
    @IBOutlet var heightConstraintForCategoryImage: NSLayoutConstraint!
    @IBOutlet var heightConstraintForTransmissionImage: NSLayoutConstraint!
    
    @IBOutlet var transmissionImageView: UIImageView!
    @IBOutlet var transmitButton: UIButton!
    
    @IBOutlet var rotateButton: UIButton!
    @IBOutlet var imageCancelButton: UIButton!
    @IBOutlet var countLabel: UILabel!
    
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var x: CGFloat = 0
    let imagePicker = UIImagePickerController()
    var chosenImage: UIImage? = UIImage()
    var transmissionImage: UIImage? = UIImage()
    var constellationId: Int = 0
    var apiKey :String = ""
    var api: APIController?
    var toUserName :String = "",fromUserName :String = "", bodyContent :String = "", selectedCategoryId :String = "1", selectedDurationId = ""
    var categoryIds = ["4", "8", "7", "2", "5", "3", "6", "1"]
    var categories = ["Claims(& Manifestations)", "Confessions(& Secrets)", "Help(& Advice)", "Love(& Romance)", "Memorials(& Prayers)", "Thanks (& Gratitude)", "Thoughts (& Rhetoric)", "Wishes (& Desires)"]
    var durationIds = ["1", "2", "3", "6", "7", "8", "9", "10", "11", "4"]
    var durations = ["1 Day", "3 Days", "1 Week", "2 Weeks", "1 Month", "3 Months", "6 Months", "9 Months", "1 Year", "Infinite"]
    var constellations = NSMutableArray()
    var constellationIds = NSMutableArray()
    var selectedConstellations = NSMutableArray()
    var selectedConstellationIds = NSMutableArray()
    
    var transmissionId: Int?
    var editFlag: Int = 0
    var transmissionDetails: NSDictionary?
    var defaultUserName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rotateButton.hidden = true
        self.imageCancelButton.hidden = true
        
        fromUserNameText.userInteractionEnabled = false
        fromUserNameText.delegate = self
        
        imagePicker.delegate = self
        
        self.tabBarController?.tabBar.hidden = true
        
        if let defaultUserName = self.defaults.objectForKey("defaultUserName") as? String {
            self.defaultUserName = defaults.objectForKey("defaultUserName") as? String
            println("default user name ==== \(self.defaultUserName)")
        }
        
        if (editFlag == 1) {
            self.transmitButton.setTitle("Update", forState: UIControlState.Normal)
            initializeDetails(transmissionDetails!)
        }
        else {
            heightConstraintForCategoryImage.constant = 0.0
            heightConstraintForCategoryText.constant = 0.0
            categorySelectedText.hidden = true
            categorySelectedImageView.hidden = true
            heghtConstraintForDurationButton.constant = 0.0
            heightConstraintForTransmissionImage.constant = 0.0
            durationTextButton.hidden = true
            bodyTextView.textColor = UIColor.lightGrayColor()
        }
        
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
//        toUserNameText.delegate = self
//        bodyText.delegate = self
        bodyTextView.delegate = self
//        bodyTextView.textColor = UIColor.lightGrayColor()
        bodyTextView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)

        self.automaticallyAdjustsScrollViewInsets = false;
         scrollView.contentSize.height = 900
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.hidden = true
        self.view.userInteractionEnabled = true
        
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        api!.delegate = self
        
        constellations = api!.userConstellations
        constellationIds = api!.userConstellationIds
        fromUserNameText.text = api!.defaultUserName
        
        apiKey = api!.apiKey
        
        
        if let constellationIsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
            
            self.constellations = defaults.objectForKey("userConstellations") as NSMutableArray
            //self.selectedConstellations = self.constellations
            
            if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                
                self.constellationIds = defaults.objectForKey("userConstellationIds") as NSMutableArray
                //self.selectedConstellationIds = self.constellationIds
                
            }
        }
        
        
    }
    
    @IBAction func editUserNameButtonClicked(sender: AnyObject) {
        
        fromUserNameText.userInteractionEnabled = true
        fromUserNameText.becomeFirstResponder()
    }
    
    
    func initializeDetails(transmissionDetails: NSDictionary) {
        
        println("editFlag======= \(editFlag)")
        println("transmissionDetails ====== \(transmissionDetails)")
        
        self.transmissionId = transmissionDetails["id"] as? Int
        fromUserNameText.text = transmissionDetails["from_username"] as NSString
        toUserNameText.text = transmissionDetails["to_username"] as NSString
        bodyTextView.text = transmissionDetails["body"] as NSString
        bodyTextView.textColor = UIColor.blackColor()
        
        var toUserNameString = transmissionDetails["to_username"] as NSString
        var array = toUserNameString.componentsSeparatedByString(",")
        
        for i in 0...array.count-1 {
            self.selectedConstellations.addObject(array[i])
        }
        
        
        println("array=============\(self.selectedConstellations)")
        
        self.categorySelectedText.text = transmissionDetails["category_name"] as NSString
        var categoryId = transmissionDetails["category_id"] as Int
        self.selectedCategoryId = "\(categoryId)"
        
        let urlString: String = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(self.selectedCategoryId).png" as String
        let imgURL: NSURL? = NSURL(string: urlString)
        
        self.heightConstraintForCategoryImage.constant = 48.0
        self.heightConstraintForCategoryText.constant = 42.0
        self.categorySelectedText.hidden = false
        self.categorySelectedImageView.hidden = false
        
        self.heghtConstraintForDurationButton.constant = 42.0
        self.durationTextButton.hidden = true
        
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var categoryImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.categorySelectedImageView.image = categoryImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        var transmissionImageString: NSDictionary? = transmissionDetails["photo"]?["photo"] as? NSDictionary
        
        if (transmissionImageString != nil) {
            transmissionImageView.contentMode = .ScaleAspectFit
            
            let urlForImage:NSString = transmissionImageString?.valueForKey("url") as NSString
            
            let imgURL: NSURL? = NSURL(string: urlForImage)
            
            
            let request: NSURLRequest = NSURLRequest(URL: imgURL!)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    var transmissionImage = UIImage(data: data)
                    self.chosenImage = transmissionImage
                    // Store the image in to our cache
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.transmissionImageView.image = transmissionImage
                        self.chosenImage = transmissionImage
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
            
            self.transmissionImageView.hidden = false
            self.rotateButton.hidden = false
            self.imageCancelButton.hidden = false
        }
        else {
            self.heightConstraintForTransmissionImage.constant = 0.0
            self.transmissionImageView.hidden = true
            self.rotateButton.hidden = true
            self.imageCancelButton.hidden = true
        }
    }

    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

//    func textFieldDidBeginEditing(textField: UITextField) {
//        
//        if (textField == toUserNameText || textField == bodyText) {
//            
//            self.scrollView.setContentOffset(CGPointMake(0, 200), animated: true)
//            self .viewDidLayoutSubviews()
//            
//        }
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//      
//        if (textField == toUserNameText || textField == bodyText){
//            self.scrollView .setContentOffset(CGPointMake(0, 0), animated: true)
//            self .viewDidLayoutSubviews()
//            
//        }
//    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let urlString: String = api!.imageUrl as String
        let imgURL: NSURL? = NSURL(string: urlString)
//        let imgData = NSData(contentsOfURL: imgURL!)
//        if imgData != nil {
//            userImageView.image = UIImage(data: imgData!)
//        }
        
        
        
        let request: NSURLRequest = NSURLRequest(URL: imgURL!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
            if error == nil {
                var userImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.userImageView.image = userImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
//        self.selectedConstellations.addObject("The Universe")
        var array: Array = self.selectedConstellations as Array
        
        var stringConstellation: String = array.combine(",")
//        self.toUserName = "The Universe," + stringConstellation
        
        self.toUserNameText.text = stringConstellation
        
        if self.toUserNameText.text == "" {
            self.toUserNameText.text = "The Universe"
        }
        if stringConstellation == "No constellation found" {
            self.toUserNameText.text = "The Universe"
        }
        
        println("self.selectedConstellations ===== \(self.selectedConstellations)")
        println("self.selectedConstellationIds ===== \(self.selectedConstellationIds)")
        println("stringConstellation=====\(stringConstellation)")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        
        if self.view.window != nil {
            if bodyTextView.textColor == UIColor.lightGrayColor() {
                textView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)
            }
        }
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
            let currentText: NSString = bodyTextView.text
        let updatedText: NSString = currentText.stringByReplacingCharactersInRange(range, withString:text)
        
            if updatedText.length == 0 {
                
                bodyTextView.text = "Say whats on your mind?"
                bodyTextView.textColor = UIColor.lightGrayColor()
            
                bodyTextView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)
            
            }
            else if bodyTextView.textColor == UIColor.lightGrayColor() && countElements(text) > 0 {
                bodyTextView.text = nil
                bodyTextView.textColor = UIColor.blackColor()
            }
        
            if updatedText.length == 256 {
                
                return false
        
            }
            else {
                println("======== mdbhdsbf ========")
                var txtAfterUpdate:NSString = self.bodyTextView.text as NSString
                    txtAfterUpdate = txtAfterUpdate.stringByReplacingCharactersInRange(range, withString: text)
                countLabel.text = "\(255 - txtAfterUpdate.length)/255"
            }
        
        return true
    }
    
    @IBAction func selectCategoryButtonClicked(sender: AnyObject) {
        var alertController = UIAlertController(title: "", message: "Select Category", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.categories.count {
            var okAction = UIAlertAction(title: "\(self.categories[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                
                self.categorySelectedText.text = self.categories[i]
                self.selectedCategoryId = self.categoryIds[i]
                
                let urlString: String = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(self.selectedCategoryId).png" as String
                let imgURL: NSURL? = NSURL(string: urlString)
                
                
                let request: NSURLRequest = NSURLRequest(URL: imgURL!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        var categoryImage = UIImage(data: data)
                        
                        // Store the image in to our cache
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.categorySelectedImageView.image = categoryImage
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
                
                self.categorySelectedText.hidden = false
                self.categorySelectedImageView.hidden = false
                
                self.heightConstraintForCategoryText.constant = 42.0
                self.heightConstraintForCategoryImage.constant = 48.0
                self.heghtConstraintForDurationButton.constant = 42.0
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func durationButtonClicked(sender: AnyObject) {
        var alertController = UIAlertController(title: "", message: "Select Duration", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.durations.count {
            var okAction = UIAlertAction(title: "\(self.durations[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                println("======1=======")
                self.durationTextButton.setTitle("\(self.durations[i])", forState: UIControlState.Normal)
                println("======2=======")
                self.selectedDurationId = self.durationIds[i]
                println("======3=======")
                
                self.heghtConstraintForDurationButton.constant = 42.0
                println("======4=======")
                self.durationTextButton.hidden = false
                println("======5=======")
                
                println("Ok Pressed")
                
                
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectImageButtonClicked(sender: AnyObject) {
        
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
//            self.imagePicker.popoverPresentationController?.sourceRect = self.view.bounds
            println("====11111111=====")
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            println("====22222222=====")
            //4
            //        imagePicker.popoverPresentationController?.barButtonItem = sender as UIBarButtonItem
            
            
        }
        println("====3333333=====")
        alertController.addAction(galleryAction)
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
        
        
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
//        {
//            println("=========phoneeeeee=========")
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
//        else {
//            println("=======ipaddddd=========")
//            var popup: UIPopoverController = UIPopoverController(contentViewController: alertController)
//
//            alertController.popoverPresentationController?.sourceRect = self.view.bounds
//            self.presentViewController(alertController, animated: true, completion: nil)
//            
//        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage //2
        transmissionImageView.contentMode = .ScaleAspectFit //3
        transmissionImageView.image = chosenImage //4
        
        self.transmissionImageView.hidden = false
        heightConstraintForTransmissionImage.constant = 145.0
        self.rotateButton.hidden = false
        self.imageCancelButton.hidden = false
        
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func rotateButtonClicked(sender: AnyObject) {
        
        println("======= x = \(x)")
        x = x + 90
        if x >= 360 {
            self.x = 0
        }
        UIView.animateWithDuration(2.0, animations: {
            self.transmissionImageView.transform = CGAffineTransformMakeRotation((self.x * CGFloat(M_PI)) / 180.0)
        })
        
    }
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
    
        transmissionImageView.hidden = true
        heightConstraintForTransmissionImage.constant = 0.0
        //transmissionImageView.removeFromSuperview()
       // transmissionImageView = nil
        chosenImage = nil
        rotateButton.hidden = true
        imageCancelButton.hidden = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        if let constellationIsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
//            
//            self.constellations = defaults.objectForKey("userConstellations") as NSMutableArray
//            self.selectedConstellations = self.constellations
//            
//            if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
//                
//                self.constellationIds = defaults.objectForKey("userConstellationIds") as NSMutableArray
//                self.selectedConstellationIds = self.constellationIds
//                
//            }
//        }
        
        var selectConstellationViewController: SelectConstellationViewController = segue.destinationViewController as SelectConstellationViewController
        selectConstellationViewController.constellations = self.selectedConstellations
        selectConstellationViewController.constellationIds = self.selectedConstellationIds
        selectConstellationViewController.wholeConstellations = self.constellations
        selectConstellationViewController.wholeConstellationIds = self.constellationIds
        
//        //            var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
//        
//        constellationViewController.constellationDetails = self.userConstellationDetails.objectAtIndex(sender!.tag) as? NSDictionary
        
    }
    
    @IBAction func selectConstellationButtonClicked(sender: AnyObject) {
        
//        if let constellationIsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
//            self.constellations = defaults.objectForKey("userConstellations") as NSMutableArray
//            if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
//                self.constellationIds = defaults.objectForKey("userConstellationIds") as NSMutableArray
//            }
//        }
//        if self.constellations.count == 0 {
//            println("====self constellation = 0=====")
////            self.fetchConstellations()
//        }
//        else {
//            showConstellations()
//        }
        
    }
    
    func showConstellations() {
        
        var alertController = UIAlertController(title: "", message: "Select Constellation", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.constellations.count {
            var okAction = UIAlertAction(title: "\(self.constellations[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                
                self.toUserNameText.text = self.constellations[i] as String
                self.constellationId = self.constellationIds[i] as Int
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func fetchConstellations() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var url : String = "http://\(GlobalVariable.apiUrl)/api/constellations/fetch_constellations.json?api_key=\(apiKey)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                dispatch_async(dispatch_get_main_queue(), {
                if (jsonResult.objectForKey("constellations") != nil) {
                    var constellations :NSArray = jsonResult["constellations"] as NSArray
                    for constellation in constellations {
                        var eachConstellation: NSDictionary = constellation as NSDictionary
                        //                        println("eachConstellation = \(eachConstellation)")
                        var constellationName: String = eachConstellation["name"] as String
                        var constellationId: Int = eachConstellation["id"] as Int
                        self.constellations.addObject(constellationName)
                        self.constellationIds.addObject(constellationId)
                    }
                    if let userConstellationsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
                        
                    } else {
                        
                        self.defaults.setObject(self.constellations, forKey: "userConstellations")
                        
                    }
                    
                    if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                        
                    } else {
                        
                        self.defaults.setObject(self.constellationIds, forKey: "userConstellationIds")
                        //
                    }
                    
                }
                
                else {
                    self.constellations.addObject("No constellation found")
                    self.constellationIds.addObject("0")
                }
                
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }
    }
    
    
    
    func takeInputData() {
        fromUserName = fromUserNameText.text
        toUserName = join(" ",toUserNameText.text.componentsSeparatedByString(" "))
        //        body = bodyText.text
        
        var bodyData = bodyTextView.text.componentsSeparatedByString(" ")
        bodyContent = join(" ", bodyData)
        //        category = selectCategoryText.text
    }
    
    func compressImage(image:UIImage?) -> NSData? {
        // Reducing file size to a 10th
        
        var actualHeight : CGFloat = image!.size.height
        var actualWidth : CGFloat = image!.size.width
        var maxHeight : CGFloat = 1136.0
        var maxWidth : CGFloat = 640.0
        var imgRatio : CGFloat = actualWidth/actualHeight
        var maxRatio : CGFloat = maxWidth/maxHeight
        var compressionQuality : CGFloat = 0.5
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
                compressionQuality = 1;
            }
        }
        
        var rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image?.drawInRect(rect)
        var img = UIGraphicsGetImageFromCurrentImageContext();
        var imageData: NSData?
         UIGraphicsEndImageContext();
        if img == nil {
            return nil
        }
        else {
             return UIImageJPEGRepresentation(img, compressionQuality)
        }
    }
    
    func editTransmission() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        
        takeInputData()
        println(" === x = \(x) ==== in transmitData")
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        
        var url = "http://\(GlobalVariable.apiUrl)/api/transmissions/update_transmission.json?"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        //        var testImage = UIImage(named: "logo.png") as UIImage?
        //        var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
        //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
        //        var imageData = nil
        
        var imageData: NSData?
        if chosenImage != nil {
            imageData = compressImage(chosenImage!)
        }
        
        var base64String = ""
        
        var constellationArray: Array = self.selectedConstellationIds as Array
        var constellationString: String = constellationArray.combine(",")
        
        println("constellationidstring ====== constellationString")
        println("==== constellationString ====== \(constellationString)")
        println("==== to_username ====== \(toUserName)")
        
        println("====transmissioId === \(self.transmissionId!)")
//        var params = ["api_key":apiKey, "transmission_id": "\(self.transmissionId!)"] as Dictionary
        var params = ["api_key":apiKey, "transmission_id": "\(self.transmissionId!)", "from_username":fromUserName, "category_id":selectedCategoryId, "preset_duration_id":selectedDurationId, "body":bodyContent, "to_username":toUserName, "to_constellation": constellationString] as Dictionary
        
        
        if imageData != nil {
            println("===========length of data not equal to zero==========")
            base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            params = ["photo": base64String, "api_key":apiKey, "transmission_id": "\(self.transmissionId!)",  "from_username":fromUserName, "category_id":selectedCategoryId, "preset_duration_id":selectedDurationId, "body":bodyContent, "to_username":toUserName, "trans_img_rotate_angle":"\(self.x)", "to_constellation": constellationString] as Dictionary
        }
        
        println("params======\(params)")
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
                
            }
            else {
                
                println("====== \(json) ======")
                
                
                if (json != nil) {
                    var transmissionId :NSString? = json?.valueForKey("update") as? NSString
                    if json?.valueForKey("update") != nil {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Transmission updated successfully", preferredStyle: UIAlertControllerStyle.Alert)
                            //                        //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                println("Ok Pressed")
                                //
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                                //
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                appDelegate.toYouController()
                                
                                
                                //                                var storyboard = UIStoryboard(name: "Main", bundle: nil)
                                //                                var initialViewController: UITabBarController =  storyboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
                                //                                initialViewController.hidesBottomBarWhenPushed = false
                                //                                initialViewController.selectedIndex = 1
                                //                                self.presentViewController(initialViewController, animated: true, completion: nil)
                                //
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
                    
                }
                else {
                    println(" === nil ==== ")
                    // couldn't load JSON, look at error
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                
                
                
                
                return
            }
        })
        //
        task.resume()
        }
    }
    
    func transmitData() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        takeInputData()
        
        println(" === x = \(x) ==== in transmitData")
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        
        var url = "http://\(GlobalVariable.apiUrl)/api/transmissions/adding_transmission.json?"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        //        var testImage = UIImage(named: "logo.png") as UIImage?
//        var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
        //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
//        var imageData = nil
        var imageData: NSData?
        if chosenImage != nil {
            imageData = compressImage(chosenImage!)
        }
        
        var base64String = ""
        
        var constellationArray: Array = self.selectedConstellationIds as Array
        var constellationString: String = constellationArray.combine(",")
        
        println("==== constellationString ====== \(constellationString)")
        println("==== to_username ====== \(toUserName)")
        
        var params = ["api_key":apiKey, "from_username":fromUserName, "category_id":selectedCategoryId, "preset_duration_id":selectedDurationId, "body":bodyContent, "to_username":toUserName, "trans_img_rotate_angle":"\(self.x)", "to_constellation": constellationString] as Dictionary
        
        if imageData != nil {
            println("length of data not equal to zero")
            base64String = imageData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            params = ["photo": base64String, "api_key":apiKey, "from_username":fromUserName, "category_id":selectedCategoryId, "preset_duration_id":selectedDurationId, "body":bodyContent, "to_username":toUserName, "trans_img_rotate_angle":"\(self.x)", "to_constellation": constellationString] as Dictionary
        }
        
        println("========params========\(params)")

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
            
            println("======json=======\(json)")
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
                    var transmissionId :NSString? = json?.valueForKey("transmission_id") as? NSString
                    if json?.valueForKey("transmission_id") != nil {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Transmission Added successfully", preferredStyle: UIAlertControllerStyle.Alert)
                            //                        //Creating actions
                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                println("Ok Pressed")
                                //
                                self.activityIndicatorView.stopAnimating()
                                self.activityIndicatorView.hidden = true
                                self.view.userInteractionEnabled = true
                                //
                                
//                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//                                appDelegate.toYouController()
//                                self.setAfterTransmit()
                                
                                self.navigationController?.popViewControllerAnimated(true)
                                

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
                        var errorMessage: NSDictionary = (json["validations"] as NSDictionary)
                        let alertController = UIAlertController(title: "", message: "\(errorMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                            
//                            self.setAfterTransmit()
                        }
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                }
                else {
                    println(" === nil ==== ")
                    // couldn't load JSON, look at error
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                
                return
            }
        })
        //
        task.resume()
            
        }
    }
    
    func setAfterTransmit() {
        
        fromUserNameText.text = api!.defaultUserName
        toUserNameText.text = "The Universe"
        bodyTextView.text = "Say whats on your mind?"
        bodyTextView.textColor = UIColor.lightGrayColor()
        bodyTextView.selectedTextRange = bodyTextView.textRangeFromPosition(bodyTextView.beginningOfDocument, toPosition: bodyTextView.beginningOfDocument)
        
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
    
    
    @IBAction func transmitButtonClicked(sender: AnyObject) {
        
        var title = sender.titleForState(.Normal)
        
        if bodyTextView.textColor == UIColor.lightGrayColor() {
            var alertController = UIAlertController(title: "", message: "Message body can't be blank.", preferredStyle: UIAlertControllerStyle.Alert)
            //                        //Creating actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
               
            }
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        else if title == "Transmit" {
            transmitData()
        }
        else if title == "Update" {
            editTransmission()
        }
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
    }
    
}

extension NSMutableData {
    func appendString(string: String) {
        //        println("String = \(string)")
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
        //        println("data = \(data)")
    }
}
