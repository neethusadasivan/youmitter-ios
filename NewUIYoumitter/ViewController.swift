//
//  ViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 20/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

import AddressBook
import MediaPlayer
import AssetsLibrary
import CoreLocation
import CoreMotion

struct GlobalVariable {
    static var apiUrl = "www.youmitter.com"
}

var api_key :String = ""
var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()

class ViewController: UIViewController, APIControllerProtocol, UITextFieldDelegate, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UIScrollViewDelegate {

    @IBOutlet var youmitterLogo: UIImageView!
    @IBOutlet var faceBookLoginView: UIView!
    @IBOutlet var fbLoginView: FBSDKLoginButton!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userName: UITextField!
    @IBOutlet var passWord: UITextField!
    @IBOutlet var faceBookLoginButton: UIButton!
    @IBOutlet var googlePlusButton: GIDSignInButton!
    
    @IBOutlet var gPlusButton: GIDSignInButton!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var userConstellations: NSMutableArray = NSMutableArray()
    var userConstellationIds: NSMutableArray = NSMutableArray()
    var fbUserName :String = "",email :String = ""
    var api: APIController?
//    var signIn : GPPSignIn?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        scrollView.delegate = self
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
//        scrollView.contentSize.height = 2000
//        scrollView.automaticallyAdjustsScrollViewInsets = false
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        api = APIController(delegate: self)
        api!.delegate = self
        passWord.delegate = self
        userName.delegate = self
        
        if let apiKeyIsNotNill = defaults.objectForKey("apiKey") as? String {
            println("===== \(apiKeyIsNotNill) =====")
            NSOperationQueue.mainQueue().addOperationWithBlock {
                self.performSegueWithIdentifier("universeView", sender: self)
            }
        }
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
        }
        else
        {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            loginView.setTranslatesAutoresizingMaskIntoConstraints(false)
//            for view in loginView.subviews as [UIView]
//            {
//                if view.isKindOfClass(UIButton)
//                {
//                    var btn = view as UIButton;
//                    let image = UIImage(named: "facebook-login.png") as UIImage?
//                    btn.setBackgroundImage(image, forState: .Normal)
//                    btn.setBackgroundImage(image, forState: .Selected)
//                    btn.setBackgroundImage(image, forState: .Highlighted)
//                    
//                }
//                if view.isKindOfClass(UILabel)
//                {
//                    var lbl = view as UILabel;
//                    lbl.text = "Log in to facebook";
//                    
//                }
//            }
            

            
//            self.faceBookLoginView.addSubview(loginView)
            self.view.addSubview(loginView)
            
//            for subView in loginView.subviews
//            {
//                subView.removeFromSuperview()
//            }
//            loginView.layer.shadowColor = UIColor.clearColor().CGColor
            
            
//            loginView.frame.size.width = userName.frame.size.width
            let widthConstraint = NSLayoutConstraint(item: loginView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: gPlusButton, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -13)
            self.view.addConstraint(widthConstraint)
            
            let horizontalConstraint = NSLayoutConstraint(item: loginView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: gPlusButton, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            self.view.addConstraint(horizontalConstraint)
            
            let verticalConstraint = NSLayoutConstraint(item: loginView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: faceBookLoginView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            self.view.addConstraint(verticalConstraint)
            
            let heightConstraint = NSLayoutConstraint(item: loginView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: gPlusButton, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: -10)
            self.view.addConstraint(heightConstraint)
            
            println("====userName.frame.size.width====\(userName.frame.size.width)")
            println("====widthConstraint=====\(widthConstraint)")
            
            loginView.center = CGPointMake(self.faceBookLoginView.frame.size.width/2,
                self.faceBookLoginView.frame.size.height/2)
            
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.delegate = self
            
//            GIDSignIn.sharedInstance().uiDelegate = self
            
        }
    }
    
    //*****************//
    
    // Implement these methods only if the GIDSignInUIDelegate is not a subclass of
    // UIViewController.
    
    // Stop the UIActivityIndicatorView animation that was started when the user
    // pressed the Sign In button
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
//        myActivityIndicator.stopAnimating()
        println("====after login======")
        
//        self.activityIndicatorView.startAnimating()
//        self.activityIndicatorView.hidden = false
//        self.view.userInteractionEnabled = false
        
        println("======user.profile.name==== \(GIDSignIn.sharedInstance().currentUser)=====")
                if (GIDSignIn.sharedInstance().currentUser != nil) {
                    println("=====GIDSignIn.sharedInstance().currentUser===\(GIDSignIn.sharedInstance().currentUser)")
                    let user = GIDSignIn.sharedInstance().currentUser
        
                    var userDetails = user.profile.name
                    println("======user.profile.name==== \(user.profile.name)=====")
                    
                    var fullNameArr = split(userDetails) {$0 == " "}
                    var firstName: String = fullNameArr[0]
                    var lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
                    
//                    var firstName = user.name.givenName
//                    var lastName = user.name.familyName
//
                    println("===firstName = \(firstName)")
                    println("===lastName = \(lastName!)")
//
//                    println()
                    if (user.profile.email != nil){
                          println("====user.profile.email=\(user.profile.email)===")
//                        print(user.emails.first? ?? "no email")
//                        var email = signIn?.userEmail!
                        var email = user.profile.email
                        callAfterLoginWithGoogle(firstName,lastName: lastName!,email: email!)
//
                    } else {
                        print("no email")
                    }
                } else {
                    println("User ID is nil")
                }
        
        
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            println("=======google sign in clicked========")
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            println("====invokes this method======")
            
            self.dismissViewControllerAnimated(true, completion: nil)
            if (GIDSignIn.sharedInstance().currentUser != nil) {
                println("=====not nil=====")
                
            }
            else {
                
                println("=====yes nil=======")
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            
    }
    //*****************//
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:10, height:800)
        
        if (self.view.bounds.size.height == 800) {
            scrollView.frame = CGRectMake(0, 0, 320, 436); // 436 allows 44 for navBar
        }
        
    }
    
    
    /*
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
            self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        println("===view will appear=====")
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.faceBookLoginView.addSubview(loginView)
        
        loginView.center = CGPointMake(self.faceBookLoginView.frame.size.width  / 2,
            self.faceBookLoginView.frame.size.height / 2)
////        let width = gPlusButton.width
//        let heightConstraint = NSLayoutConstraint(item: loginView, attribute: NSLayoutAttributeWidth, relatedBy: NSLayoutRelation.Equal, toItem: gPlusButton!, attribute: NSLayoutAttributeWidth, multiplier: 1, constant: 0)
//        loginView.addConstraints([heightConstraint])
////        loginView.width = googlePlusButton.width
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
        
//        signIn = GPPSignIn.sharedInstance()
        
        /*
        signIn?.shouldFetchGooglePlusUser = true
        signIn?.shouldFetchGoogleUserEmail = true  // Uncomment to get the user's email
        signIn?.shouldFetchGoogleUserID = true
        signIn?.clientID = "343632549234-c1ocb3med2rou2rl4ou18e249cr4q6fu.apps.googleusercontent.com"
        signIn?.scopes = [kGTLAuthScopePlusLogin]
        signIn?.delegate = self
        */
        
//        signIn?.authenticate()
        
    }
    
    // Login with googlePlusButton
    @IBAction func googlePlusButtonClicked(sender: AnyObject) {
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        GIDSignIn.sharedInstance().signIn()
        /*
        signIn = GPPSignIn.sharedInstance()
        signIn?.shouldFetchGooglePlusUser = true
        signIn?.shouldFetchGoogleUserEmail = true  // Uncomment to get the user's email
        signIn?.shouldFetchGoogleUserID = true
        signIn?.clientID = "343632549234-c1ocb3med2rou2rl4ou18e249cr4q6fu.apps.googleusercontent.com"
        signIn?.scopes = [kGTLAuthScopePlusLogin]
        signIn?.delegate = self
        signIn?.authenticate()
        */
        
    }
        
    
//    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
    
        
//        if (GPPSignIn.sharedInstance().userID != nil) {
//            let user = GPPSignIn.sharedInstance().googlePlusUser
//            
//            var userDetails = user.name
//            var firstName = user.name.givenName
//            var lastName = user.name.familyName
//            
//            println("===firstName = \(firstName)")
//            println("===lastName = \(lastName)")
//            
//            println()
//            if (user.emails != nil){
//                
//                print(user.emails.first? ?? "no email")
//                var email = signIn?.userEmail!
//                callAfterLoginWithGoogle(firstName,lastName: lastName,email: email!)
//                
//            } else {
//                print("no email")
//            }
//        } else {
//            println("User ID is nil")
//        }
        
//    }
    
    func didDisconnectWithError(error: NSError!) {
        println("===== didDisconnectWithError ========")
    }
    
    func callAfterLoginWithGoogle(firstName: String, lastName: String, email: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
            println("=====swift self=====\(self)=====")
//        self.activityIndicatorView.startAnimating()
//        self.activityIndicatorView.hidden = false
//        self.view.userInteractionEnabled = false
        
        println("firstName = \(firstName)")
        println("lastName = \(lastName)")
        println("email = \(email)")
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/sign_in_with_fb_ggle.json?provider=googleplus&uid=&first_name=\(firstName)&last_name=\(lastName)&email=\(email)"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
        //        var fullNameArr = split(name) {$0 == " "}
        //        var firstName: String = fullNameArr[0]
        //        var lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
        //
        println("======firstName =====\(firstName)")
        println("======lastName =====\(lastName)")
        
        //        var params = ["provider": "facebook", "uid": uid, "first_name": "neethu", "last_name": "sadasivan"] as Dictionary
        //
        //        let boundary = generateBoundaryString()
        //        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //
        //        request.HTTPBody = createBodyWithParameters(params, filePathKey: "file", boundary: boundary)
        
        
        
        //        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
                    var authenticationStatus :NSString? = json?.valueForKey("authentication") as? NSString
                    if authenticationStatus == "Sucess" {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            //                            var alertController = UIAlertController(title: "", message: "Logged in successfully", preferredStyle: UIAlertControllerStyle.Alert)
                            //                            //                        //Creating actions
                            //                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            //                                UIAlertAction in
                            //                                println("Ok Pressed")
                            //
                            //
                            
                            println("======= \(authenticationStatus) 11111=======")
                            
                            var api_key = json["api_key"] as NSString
                            //                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                            
                            
                            //                    self.fetchConstellations(api_key)
                            //                    self.api!.fetchUserConstellations(api_key)
                            defaults.setObject(api_key, forKey: "apiKey")
                            
                            var user_name = json["username"] as String
                            
                            defaults.setObject(user_name, forKey: "userName")
                            
                            var name = json["name"] as String
                            
                            defaults.setObject(name, forKey: "name")
                            
                            var image_url = json["image_url"] as String
                            
                            defaults.setObject(image_url, forKey: "imageUrl")
                            
                            defaults.setObject("random", forKey: "transType")
                            
                            defaults.setObject("off", forKey: "shareMedia")
                            
                            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                            appDelegate.homeButtonClicked()
                            
                            //                                var storyboard = UIStoryboard(name: "Main", bundle: nil)
                            //                                var initialViewController: UITabBarController =  storyboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
                            //                                initialViewController.hidesBottomBarWhenPushed = false
                            //                                initialViewController.selectedIndex = 0
                            //                                self.presentViewController(initialViewController, animated: true, completion: nil)
                            
 //                           self.activityIndicatorView.stopAnimating()
 //                           self.activityIndicatorView.hidden = true
 //                           self.view.userInteractionEnabled = true
                            
                            //
                            //                            }
                            //                            //                        //Creating actions
                            //                            alertController.addAction(okAction)
                            //                            self.presentViewController(alertController, animated: true, completion: nil)
                            //
                            //                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                        }
                        
                    }
                        
                    else {
                        println("======== else part ========")
                        var errorMessage: String = (json["error"] as String)
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
    
    // Login with googlePlusButton
    
    
    
    
    // Facebook Delegate Methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        println("User Logged In")
        println("====== result = \(result) ======")
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            println("result not cancelled")
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
//            var data: Array = result.grantedPermissions as Array
            var arr = result.grantedPermissions.allObjects
            println("arr ==== \(arr)")
             self.returnUserData()
//            if data.contains("email")
//            {
//                println("=========data======\(data)========")
//            }
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }

    func returnUserData()
    {
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                println("Error: \(error)")
            }
            else
            {
                var userId : NSString = ""
                var userName : NSString = ""
                if result.valueForKey("id") != nil {
                    userId = result.valueForKey("id") as NSString
                    println("User Id is: \(userId)")
                }
                println("fetched user: \(result)")
                userName = result.valueForKey("name") as NSString
                println("User Name is: \(userName)")
                if result.valueForKey("email") != nil {
                    let userEmail : NSString = result.valueForKey("email") as NSString
                    println("User Email is: \(userEmail)")
                }
                if result.valueForKey("contact_email") != nil {
                    let cotactEmail : NSString = result.valueForKey("contact_email") as NSString
                    println("Contact Email is: \(cotactEmail)")
                }
                self.callAfterLoginWithFb(userId,name: userName)
            }
        })
    }
    
    
    func callAfterLoginWithFb(uid: String, name: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var fullNameArr = split(name) {$0 == " "}
        var firstName: String = fullNameArr[0]
        var lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
        
        var emailFB: String = "\(firstName)\(lastName!)"
        println("emailFB === \(emailFB)")
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/sign_in_with_fb_ggle.json?provider=facebook&uid=\(uid)&first_name=\(firstName)&last_name=\(lastName!)&email=\(emailFB)@facebook.com"
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "GET"
        
//        var fullNameArr = split(name) {$0 == " "}
//        var firstName: String = fullNameArr[0]
//        var lastName: String? = fullNameArr.count > 1 ? fullNameArr[1] : nil
//        
        println("======firstName =====\(firstName)")
        println("======lastName =====\(lastName)")
        
//        var params = ["provider": "facebook", "uid": uid, "first_name": "neethu", "last_name": "sadasivan"] as Dictionary
//        
//        let boundary = generateBoundaryString()
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        
//        request.HTTPBody = createBodyWithParameters(params, filePathKey: "file", boundary: boundary)

        
        
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
                    var authenticationStatus :NSString? = json?.valueForKey("authentication") as? NSString
                    if authenticationStatus == "Sucess" {
                        
                        dispatch_async(dispatch_get_main_queue()) {
//                            var alertController = UIAlertController(title: "", message: "Logged in successfully", preferredStyle: UIAlertControllerStyle.Alert)
//                            //                        //Creating actions
//                            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//                                UIAlertAction in
//                                println("Ok Pressed")
                                //
                                                                //
                            
                                println("======= \(authenticationStatus) 11111=======")
                                
                                var api_key = json["api_key"] as NSString
                                //                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                                
                                
                                //                    self.fetchConstellations(api_key)
                                //                    self.api!.fetchUserConstellations(api_key)
                                defaults.setObject(api_key, forKey: "apiKey")
                                
                                var user_name = json["username"] as String
                                
                                defaults.setObject(user_name, forKey: "userName")
                                
                                var name = json["name"] as String
                                
                                defaults.setObject(name, forKey: "name")
                                
                                var image_url = json["image_url"] as String
                                
                                defaults.setObject(image_url, forKey: "imageUrl")
                                
                                defaults.setObject("random", forKey: "transType")
                                
                                defaults.setObject("off", forKey: "shareMedia")
                            
                                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                                appDelegate.homeButtonClicked()
                            
//                                var storyboard = UIStoryboard(name: "Main", bundle: nil)
//                                var initialViewController: UITabBarController =  storyboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
//                                initialViewController.hidesBottomBarWhenPushed = false
//                                initialViewController.selectedIndex = 0
//                                self.presentViewController(initialViewController, animated: true, completion: nil)
                            
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true

                                //
//                            }
//                            //                        //Creating actions
//                            alertController.addAction(okAction)
//                            self.presentViewController(alertController, animated: true, completion: nil)
                            //
                            //                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                        }
                        
                    }
                        
                    else {
                        println("======== else part ========")
                        var errorMessage: String = (json["error"] as String)
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
        //-----------------------------------------------
        
        
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
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        println("=======jjjjjjjjj")
        if (textField == passWord || textField == userName) {
            self.scrollView.setContentOffset(CGPointMake(0, 200), animated: true)
            self .viewDidLayoutSubviews()
            
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        println("=====kkkkkkkkk")
        if (textField == passWord || textField == userName){
//            self.scrollView .setContentOffset(CGPointMake(0, 0), animated: true)
            self .viewDidLayoutSubviews()
        
        }
    }

    func scrollViewDidScroll(scrollView: UIScrollView!) {

    }
    
    
    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
   
    
    func fetchConstellations(apiKey: String) {
        
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
                        self.userConstellations.addObject(constellationName)
                        self.userConstellationIds.addObject(constellationId)
                    }
                    if let userConstellationsNotNill = defaults.objectForKey("userConstellations") as? NSMutableArray {
                        
                    } else {
                        
                        defaults.setObject(self.userConstellations, forKey: "userConstellations")
                        
                    }
                    
                    if let userConstellationIdsNotNill = defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                        
                    } else {
                        
                        defaults.setObject(self.userConstellationIds, forKey: "userConstellationIds")
                        //
                    }
                    
                }
                
                
                
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }
    }
    
    func loginAction() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var user = true
        var userNameText = userName.text
        var passWordText = passWord.text
        //        let urlPath = "http://\(GlobalVariable.apiUrl)/api/sign_in.json?username=\(userNameText)&password=\(passWordText)"
        
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/sign_in.json?username=\(userNameText)&password=\(passWordText)"
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "GET"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                // process jsonResult
                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                
                if authenticationStatus == "Sucess" {
                    println("======= \(authenticationStatus) 11111=======")
                    
                    api_key = jsonResult["api_key"] as NSString
                    //                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    
                    
                    //                    self.fetchConstellations(api_key)
//                    self.api!.fetchUserConstellations(api_key)
                    defaults.setObject(api_key, forKey: "apiKey")
                    
                    var user_name = jsonResult["username"] as String
                    
                    defaults.setObject(user_name, forKey: "userName")
                    
                    var name = jsonResult["name"] as String
                    
                    defaults.setObject(name, forKey: "name")
                    
                    var image_url = jsonResult["image_url"] as String
                    
                    defaults.setObject(image_url, forKey: "imageUrl")
                    
                    defaults.setObject("random", forKey: "transType")
                    
                    defaults.setObject("off", forKey: "shareMedia")
                    //                    defaults.synch`ronize()
                    
                    
//                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        self.performSegueWithIdentifier("universeView", sender: self)
//                    }
                    
                    
                    
                    println("connected")
//                    NSOperationQueue.mainQueue().addOperationWithBlock {
//                        dispatch_async(dispatch_get_main_queue()) {
//                                                self.performSegueWithIdentifier("universeView", sender: self)
//                      }                      }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.hidden = true
                        self.view.userInteractionEnabled = true

                        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                        appDelegate.homeButtonClicked()
                    }
                }
                else {
                    println("failed to login")
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Authentication failed.", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
                // couldn't load JSON, look at error
                println("couldnt get the results")
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "", message: "Unable to login.", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        println("Ok Pressed")
                        
                    }
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    
                }
                
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
            
        })
            
        }
        
    }
    
    @IBAction func manualLogin(sender: AnyObject) {
        
        println("Login clicked")
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            loginAction()
            println("after login")
        }
        else {
            println("Internet connection FAILED")
            
            let alertController = UIAlertController(title: "", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            
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
    
    @IBAction func signUpButtonClicked(sender: AnyObject) {
        
//        NSOperationQueue.mainQueue().addOperationWithBlock {
//            self.performSegueWithIdentifier("signUpView", sender: self)
//        }
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
    }
    
}

