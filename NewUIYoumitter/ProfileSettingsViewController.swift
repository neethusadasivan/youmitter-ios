//
//  ProfileSettingsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 04/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController, ENSideMenuDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, APIControllerProtocol {
    
    @IBOutlet var sideMenuButton: UIBarButtonItem!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameText: UITextField!
    @IBOutlet var firstNameText: UITextField!
    @IBOutlet var lastNameText: UITextField!
    @IBOutlet var emailText: UITextField!
    @IBOutlet var postelCodeText: UITextField!
    @IBOutlet var phoneNumberText: UITextField!
    @IBOutlet var countryText: UITextField!
    @IBOutlet var streetAddressText: UITextField!
    @IBOutlet var cityText: UITextField!
    @IBOutlet var stateText: UITextField!
    @IBOutlet var obscureLocationSwitch: UISwitch!
    @IBOutlet var defaultUserNameButton1: UIButton!
    @IBOutlet var defaultUserNameButton2: UIButton!
    @IBOutlet var userInterestButton: UIButton!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var alertResponseLabel: UILabel?
    @IBOutlet var actionResponseLabel: UILabel?
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var rotationButtonImageView: UIButton!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    var userName: String = "", firstName: String = "", lastName: String = "", emailId: String = "", postalCode: String = "", phoneNumber: String = "", country: String = "", streetAddress: String = "", city: String = "", state: String = "", defaultUserName: String = "";
    
    var obscureLocationStatus: Int = 0
    var rotationAngle: CGFloat = 0
    var checkedImage = UIImage(named: "checked") as UIImage?
    var uncheckedImage = UIImage(named: "unchecked") as UIImage?
    
    var isAnimating: Bool = false
    var dropDownViewIsDisplayed: Bool = false
    var selectedUserInterestNames : NSMutableArray = NSMutableArray()
    var selectedUserInterestIds : NSMutableArray = NSMutableArray()
    var api: APIController?
    
    var apiKey :String = ""
    var profileDetails: NSDictionary!
    var userInterests = []
    var kCellIdentifier = "userInterestCell"
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var x:CGFloat = 0
    let imagePicker = UIImagePickerController()
    var chosenImage: UIImage? = UIImage()
    var interestsToString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        
        imagePicker.delegate = self
        
        println("in viewDidLoad()")
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.sideMenuController()?.sideMenu?.delegate = self
        //        self.userNameText.delegate = self
        //        userNameText.addTarget(self, action:Selector("textDidBeginEditing"), forControlEvents: UIControlEvents.EditingDidBegin)
        //        firstNameText.addTarget(self, action:Selector("textDidBeginEditing"), forControlEvents: UIControlEvents.EditingDidBegin)
        
        
        
        //        var height: CGFloat = self.dropDownTableView.frame.size.height
        //        var width: CGFloat = self.dropDownTableView.frame.size.width
        //        self.dropDownTableView.frame = CGRectMake(0, -height, width, height)
        self.dropDownViewIsDisplayed = false
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            api!.fetchProfileDetails()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:10, height:1200)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return 10
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("userInterestCell") as UITableViewCell
        cell.textLabel.text = "haaaaii"
        return cell
    }
    
    @IBAction func userInterestsClicked(sender: AnyObject) {
        
    }
    
    
    
    func takeInputData() {
        userName = join(" ",userNameText.text.componentsSeparatedByString(" "))
//        userName = userNameText.text
        firstName = join(" ",firstNameText.text.componentsSeparatedByString(" "))
        lastName = join(" ",lastNameText.text.componentsSeparatedByString(" "))
        emailId = join(" ",emailText.text.componentsSeparatedByString(" "))
        postalCode = join(" ",postelCodeText.text.componentsSeparatedByString(" "))
        phoneNumber = join(" ",phoneNumberText.text.componentsSeparatedByString(" "))
        println("phone number === \(phoneNumber)")
        country = join(" ",countryText.text.componentsSeparatedByString(" "))
        streetAddress = join(" ",streetAddressText.text.componentsSeparatedByString(" "))
        city = join(" ",cityText.text.componentsSeparatedByString(" "))
        state = join(" ",stateText.text.componentsSeparatedByString(" "))
        println("self.userIntersetIds ======== \(self.selectedUserInterestIds)")
       // interestsToString = ",".join(self.selectedUserInterestIds)
    }
    
    @IBAction func selectProfileImageClicked(sender: AnyObject) {
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
            self.imagePicker.modalPresentationStyle = .Popover
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
        profileImageView.contentMode = .ScaleAspectFit //3
        profileImageView.image = chosenImage //4
        
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
    
    @IBAction func rotateButtonClicked(sender: AnyObject) {
        
        println("======= x = \(x)")
        x = x + 90
        if x >= 360 {
            self.x = 0
        }
        UIView.animateWithDuration(2.0, animations: {
            self.profileImageView.transform = CGAffineTransformMakeRotation((self.x * CGFloat(M_PI)) / 180.0)
        })
        
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
    
    func profileEdit() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var url = "http://\(GlobalVariable.apiUrl)/api/accounts/update_profile.json?"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "PUT"
        
        //        var testImage = UIImage(named: "logo.png") as UIImage?
        var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
        //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
        
        var base64String = ""
        var interestArray: Array = self.selectedUserInterestIds as Array
        var interestString: String = interestArray.combine(",")
        println("==== interestString ====== \(interestString)")
        
        
        
        var params = ["api_key":apiKey, "user[username]":userName, "user[first_name]":firstName, "user[last_name]":lastName, "user[email]":emailId, "user[postal_code]":postalCode, "user[phone_number]":phoneNumber,"user[country]":country, "user[street_address]":streetAddress, "user[city]":city, "user[state]":state, "user[default_username]":self.defaultUserName, "user[obscure_location]":"\(self.obscureLocationStatus)", "user_interests":interestString, "image_rot_angle":"\(self.x)"] as Dictionary
        if imageData != nil {
            base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
            params = ["new_image":base64String, "api_key":apiKey, "user[username]":userName, "user[first_name]":firstName, "user[last_name]":lastName, "user[email]":emailId, "user[postal_code]":postalCode, "user[phone_number]":phoneNumber,"user[country]":country, "user[street_address]":streetAddress, "user[city]":city, "user[state]":state, "user[default_username]":self.defaultUserName, "user[obscure_location]":"\(obscureLocationStatus)", "user_interests":interestString, "image_rot_angle":"\(self.x)"] as Dictionary
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
                
            }
            else {
                
                println("====== \(json) ======")
                
                
                if (json != nil) {
                    if json?.valueForKey("user_image") != nil {
                        
                        var imageString = json?.valueForKey("user_image") as String
                        self.defaults.setObject(imageString, forKey: "imageUrl")
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            var alertController = UIAlertController(title: "", message: "Your profile has been updated succesfully.", preferredStyle: UIAlertControllerStyle.Alert)
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
                            
                            ////                        self.performSegueWithIdentifier("universeView", sender: self)
                        }
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Your profile cannot be updated,something went wrong.", preferredStyle: UIAlertControllerStyle.Alert)
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
                
                
                
                return
            }
        })
        //
        task.resume()
        
        }
        
        //--------------------------------------------------------------------------------------------
     

    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        
        println("apikey======\(apiKey)")
        println("self.userinterestnames ===== \(self.selectedUserInterestNames)")
        println("self.userinterestids ===== \(self.selectedUserInterestIds)")
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        takeInputData()
        profileEdit()
        
////        let urlPath: String = "YOUR_URL_HERE"
//        
//        var urlPath : String = "http://\(GlobalVariable.apiUrl)/api/accounts/update_profile.json?"
//
//        var interestArray: Array = self.selectedUserInterestIds as Array
//        var interestString: String = interestArray.combine(",")
//        println("==== interestString ====== \(interestString)")
//        
//        var bodyData : NSData = ("api_key=\(apiKey)&user[username]=\(userName)&user[first_name]=\(firstName)&user[last_name]=\(lastName)&user[email]=\(emailId)&user[postal_code]=\(postalCode)&user[phone_number]= \(phoneNumber)&user[country]=\(country)&user[street_address]=\(streetAddress)&user[city]=\(city)&user[state]=\(state)&user[default_username]=\(self.defaultUserName)&user[obscure_location]=\(obscureLocationStatus)&user_interests=\(interestString)&image_rot_angle=\(self.x)").dataUsingEncoding(NSUTF8StringEncoding)!
//        
//        var imageData = UIImageJPEGRepresentation(chosenImage, 0.5)
//        //        var imageData = UIImageJPEGRepresentation(testImage, 0.9)
//        
//        var base64String = ""
//        
//        if imageData != nil {
//            
//            
//            base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0))
////            println("basestring ====== \(base64String)")
//            
//            var bodyData : NSData = ("&new_image=\(base64String)&api_key=\(apiKey)&user[username]=\(userName)&user[first_name]=\(firstName)&user[last_name]=\(lastName)&user[email]=\(emailId)&user[postal_code]=\(postalCode)&user[phone_number]= \(phoneNumber)&user[country]=\(country)&user[street_address]=\(streetAddress)&user[city]=\(city)&user[state]=\(state)&user[default_username]=\(self.defaultUserName)&user[obscure_location]=\(obscureLocationStatus)&image_rot_angle=\(self.x)").dataUsingEncoding(NSUTF8StringEncoding)!
//            
//            var urlPath : String = "http://\(GlobalVariable.apiUrl)/api/accounts/update_profile.json?"
//        }
//        
//        println("=======urlPath========\(urlPath)")
//        
//        var url: NSURL = NSURL(string: urlPath)!
//        var request : NSMutableURLRequest = NSMutableURLRequest(URL: url)
//        var session = NSURLSession.sharedSession()
//        
//        request.HTTPMethod = "PUT"
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
////
//        request.HTTPBody = bodyData
//
//        println("=======request========\(request)")
//        
//        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
////            println("Response: \(response)")
//            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
//            var err: NSError?
//            var json: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as? NSDictionary
//            
//            
//            if(err != nil) {
//                //                println(err!.localizedDescription)
//                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
//                    
//                
//                println("Error could not parse JSON: '\(jsonStr)'")
//                self.activityIndicatorView.stopAnimating()
//                self.activityIndicatorView.hidden = true
//                self.view.userInteractionEnabled = true
//            }
//            else {
//                
//                println("====== json ==== \(json) ======")
//                
//                
//                if (json != nil) {
//                    if json?.valueForKey("update") != nil {
//                        dispatch_async(dispatch_get_main_queue()) {
//                            var alertController = UIAlertController(title: "", message: "Your profile has been updated succesfully.", preferredStyle: UIAlertControllerStyle.Alert)
//                            //Creating actions
//                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//                                UIAlertAction in
//                                //                            self.api!.fetchMessages("")
//                                self.activityIndicatorView.stopAnimating()
//                                self.activityIndicatorView.hidden = true
//                                self.view.userInteractionEnabled = true
//                                
//                                
//                            }
//                            //Creating actions
//                            alertController.addAction(okAction)
//                            self.presentViewController(alertController, animated: true, completion: nil)
//                            
//                            ////                        self.performSegueWithIdentifier("universeView", sender: self)
//                        }
//                    }
//                }
//                else {
//                    dispatch_async(dispatch_get_main_queue()) {
//                        var alertController = UIAlertController(title: "", message: "Your profile cannot be updated,something went wrong.", preferredStyle: UIAlertControllerStyle.Alert)
//                        //Creating actions
//                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//                            UIAlertAction in
//                            //                            self.api!.fetchMessages("")
//                            self.activityIndicatorView.stopAnimating()
//                            self.activityIndicatorView.hidden = true
//                            self.view.userInteractionEnabled = true
//                            
//                            
//                        }
//                        //Creating actions
//                        alertController.addAction(okAction)
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                    }
//                }
//            }
//        })
//        task.resume()

        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toUserInterests" {
            
            var userInterestsController: UserIntersetSelectionViewController = segue.destinationViewController as UserIntersetSelectionViewController
            userInterestsController.userInterestNames = self.selectedUserInterestNames
            userInterestsController.userInterestIds = self.selectedUserInterestIds
//            userInterestsController.delegate? = self
            
        }
        
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
    }
    
    
    @IBAction func sideMenuClicked(sender: AnyObject) {
    }
    
    func sideMenuWillOpen() {
        println("sideMenuWillOpen")
    }
    
    func sideMenuWillClose() {
        println("sideMenuWillClose")
    }
    
    func sideMenuShouldOpenSideMenu() -> Bool {
        println("sideMenuShouldOpenSideMenu")
        return false;
    }
    
    func displayDetails() {
        self.userNameText.text = profileDetails["username"] as? String
        self.firstNameText.text = profileDetails["first_name"] as? String
        self.lastNameText.text = profileDetails["last_name"] as? String
        self.emailText.text = profileDetails["email"] as? String
        self.postelCodeText.text = profileDetails["postal_code"] as? String
        self.phoneNumberText.text = profileDetails["phone_number"] as? String
        self.countryText.text = profileDetails["country"] as? String
        self.streetAddressText.text = profileDetails["street_address"] as? String
        self.cityText.text = profileDetails["city"] as? String
        self.stateText.text = profileDetails["state"] as? String
        self.defaultUserName = profileDetails["default_username"] as String
        self.userName = profileDetails["username"] as String
        defaultUserNameButton1.setTitle("   \(self.defaultUserName)", forState: UIControlState.Normal)
        
        
        var profileImageString = profileDetails["photo"] as? String
        println("=======profileImageString=======\(profileImageString)")
        let imgURL: NSURL = NSURL(string: profileImageString!)!
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
                var profileImage = UIImage(data: data)
                
                // Store the image in to our cache
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.profileImageView.image = profileImage
                })
            }
            else {
                println("Error: \(error.localizedDescription)")
            }
        })
        
        obscureLocationStatus = profileDetails["obscure_location"] as Int
        if obscureLocationStatus == 1 {
            obscureLocationSwitch.setOn(true, animated:true)
        }
        else {
            obscureLocationSwitch.setOn(false, animated:true)
        }
        var interests: NSMutableArray = profileDetails["interests"] as NSMutableArray!
        self.userInterests = interests
        for i in 0 ..< self.userInterests.count {
            var eachUserInterest: NSDictionary = self.userInterests[i] as NSDictionary
            var interestName: String = eachUserInterest["name"] as String
            self.selectedUserInterestNames.addObject(interestName)
            var interestId: Int = eachUserInterest["id"] as Int
            self.selectedUserInterestIds.addObject(interestId)
        }
        if (self.selectedUserInterestNames.count > 0) {
           userInterestButton.setTitle("   \(self.selectedUserInterestNames[self.selectedUserInterestNames.count - 1])", forState: UIControlState.Normal)
        }
        else {
        userInterestButton.setTitle("   Select User Interests", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func obscureLocationStatusChanged(sender: AnyObject) {
        
        if obscureLocationSwitch.on {
            obscureLocationStatus = 1
        }
        else {
            obscureLocationStatus = 0
        }

    }
    
    
    @IBAction func anonymousRadioButtonClicked(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "Select Default Username", preferredStyle: UIAlertControllerStyle.Alert)
        
            var anonymousAction = UIAlertAction(title: "Anonymous", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                
                self.defaultUserName = "Anonymous"
                self.defaultUserNameButton1.setTitle("   Anonymous", forState: UIControlState.Normal)
                            }
            alertController.addAction(anonymousAction)
        
            var defaultUserNameAction = UIAlertAction(title: "\(self.userName)", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
            
                self.defaultUserName = self.userName
                self.defaultUserNameButton1.setTitle("   \(self.userName)", forState: UIControlState.Normal)
            }
        alertController.addAction(defaultUserNameAction)
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
        
    }
    
    @IBAction func defaultUserNameCheckButtonClicked(sender: AnyObject) {
        
            self.defaultUserName = self.userName
        defaultUserNameButton1.setImage(uncheckedImage, forState: UIControlState.Normal)
        defaultUserNameButton2.setImage(checkedImage, forState: UIControlState.Normal)
        
    }
    
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        //        if results.objectForKey("comments") != nil {
        //            var resultsArr: NSArray = results["comments"] as NSArray
        // Youmitter code
        //        var resultsArr: NSArray = results["results"] as NSArray
        dispatch_async(dispatch_get_main_queue(), {
            self.profileDetails = results
            self.displayDetails()
            //                self.commentsTableView!.reloadData()
            //                self.activityIndicatorView.stopAnimating()
            //                self.activityIndicatorView.hidden = true
            //                self.view.userInteractionEnabled = true
            
        })
        //        }
        //        else {
        if results.objectForKey("error") != nil {
            var error: NSString = results["error"] as NSString
            let alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                //                    self.activityIndicatorView.stopAnimating()
                //                    self.activityIndicatorView.hidden = true
                //                    self.view.userInteractionEnabled = true
            }
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
//    func UserIntersetSelectionViewResponse(interests: NSMutableArray) {
//        println("=============")
//    }
    
    @IBAction func searchMenuClicked(sender: AnyObject) {
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
////        destViewController.hidesBottomBarWhenPushed = true
////        
////        navigationController?.pushViewController(destViewController, animated: true)
//        self.presentViewController(destViewController, animated: true, completion: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.searchMenuclicked()
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
////        destViewController.hidesBottomBarWhenPushed = true
////        
////        navigationController?.pushViewController(destViewController, animated: true)
//        self.presentViewController(destViewController, animated: true, completion: nil)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.messageMenuClicked()
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
////        destViewController.hidesBottomBarWhenPushed = true
////        
////        navigationController?.pushViewController(destViewController, animated: true)
//        self.presentViewController(destViewController, animated: true,completion: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.alertMenuClicked()
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: {})
        
    }
    

}

extension Array {
    func combine(separator: String) -> String{
        var str : String = ""
        for (idx, item) in enumerate(self) {
            str += "\(item)"
            if idx < self.count-1 {
                str += separator
            }
        }
        return str
    }
}
