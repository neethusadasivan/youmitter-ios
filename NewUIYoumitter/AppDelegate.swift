//
//  AppDelegate.swift
//  NewUIYoumitter
//
//  Created by HOME on 20/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?

    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var initialViewController :UIViewController?
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
    
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        GIDSignIn.sharedInstance().delegate = self
        
        let apiKeyIsNotNill1 = defaults.objectForKey("apiKey") as? String
        println("=====apiKeyIsNotNill1======\(apiKeyIsNotNill1)")
        if let apiKeyIsNotNill = defaults.objectForKey("apiKey") as? String {
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            var storyboard = UIStoryboard(name: "Main", bundle: nil)
            initialViewController =  storyboard.instantiateViewControllerWithIdentifier("Transmissions") as? UIViewController
            
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            //            NSOperationQueue.mainQueue().addOperationWithBlock {
            //                self.performSegueWithIdentifier("universeView", sender: self)
            //            }
        }
        else {
//            println("======================= 1 ====================")
//            //        FBLoginView.self
//            println("======================= 2 ====================")
//            //        FBProfilePictureView.self
//            println("======================= 3 ====================")
//            
//            // Initialize sign-in
//            
//            GIDSignIn.sharedInstance().clientID = "343632549234-c1ocb3med2rou2rl4ou18e249cr4q6fu.apps.googleusercontent.com"
            
            // Initialize sign-in
            
//            var configureError: NSError?
//            GGLContext.sharedInstance().configureWithError(&configureError)
//            assert(configureError == nil, "Error configuring Google services: \(configureError)")
//            
//            GIDSignIn.sharedInstance().delegate = self

        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        
        if url.scheme == "fb265843223605961" {
            return FBSDKApplicationDelegate.sharedInstance().application(
                            application,
                            openURL: url,
                            sourceApplication: sourceApplication,
                           annotation: annotation)
        }
        else {
            return GIDSignIn.sharedInstance().handleURL(url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        }
        
    }
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            println("==app delegate===")
            if (error == nil) {
//                // Perform any operations on signed in user here.
//                let userId = user.userID                  // For client-side use only!
//                let idToken = user.authentication.idToken // Safe to send to the server
//                let name = user.profile.name
//                let email = user.profile.email
//                // ...
                
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
                        var viewController: ViewController = ViewController()
                        
                        viewController.callAfterLoginWithGoogle(firstName,lastName: lastName!,email: email!)
                        //
                    } else {
                        print("no email")
                    }
                } else {
                    println("User ID is nil")
                }
                
                
            } else {
                print("\(error.localizedDescription)")
            }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }

    func logOutButtonClicked() {
        println("===logout clicked===")
        GIDSignIn.sharedInstance().signOut()
        var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.removeObjectForKey("apiKey")
        defaults.removeObjectForKey("name")
        defaults.removeObjectForKey("username")
        defaults.removeObjectForKey("image_url")
        defaults.removeObjectForKey("transType")
        defaults.removeObjectForKey("shareMedia")
        defaults.removeObjectForKey("userConstellations")
        defaults.removeObjectForKey("userConstellationIds")
        defaults.removeObjectForKey("constellationDetails")
        println("===removed nsuserdefaults===")
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginViewController") as? UIViewController
        self.window?.makeKeyAndVisible()
        
    }
    
    func homeButtonClicked() {
        
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Transmissions") as? UIViewController
    }
    
    func searchMenuclicked() {
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchViewController") as? UIViewController
    }
    
    func messageMenuClicked() {
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MessagesViewController") as? UIViewController
    }
    
    func alertMenuClicked() {
        self.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("AlertsViewController") as? UIViewController
    }
    
    func toUniverseController() {

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var universeController = mainStoryboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
        
        
        var universeNavigation: UINavigationController = universeController.viewControllers?.first as UINavigationController
        
        
        let universe: UniverseController = universeNavigation.viewControllers[0] as UniverseController
        
        universe.tuneInTransmissionflag = 1
        universe.searchFlag = 2
        println("universeNavigation = \(universeNavigation.viewControllers[0])")
        universeController.selectedIndex = 0
        
        universeController.hidesBottomBarWhenPushed = false
        
        
        window?.rootViewController = universeController
        //        self.window?.rootViewController = universeController
        
        
    }

    func toYouController() {
        
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var universeController = mainStoryboard.instantiateViewControllerWithIdentifier("Transmissions") as UIViewController
//        
//        println("======universeController========\(universeController)")
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let main = storyboard.instantiateViewControllerWithIdentifier("sw_front") as UIViewController
//         println("======swrevealController========\(main)")
        
        /* Commented for side menu testing */
        
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var youController = mainStoryboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
        
        
        var youNavigation: UINavigationController = youController.viewControllers?.first as UINavigationController
        
        
//        let you: YouController = youNavigation.viewControllers[1] as YouController
        youController.selectedIndex = 1
        youController.hidesBottomBarWhenPushed = false
        window?.rootViewController = youController
        //        self.window?.rootViewController = universeController
        
        /* Commented for side menu testing */


    }

    
    func fromConstellationToUniverseController(id: Int) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var universeController = mainStoryboard.instantiateViewControllerWithIdentifier("Transmissions1") as UITabBarController
        
        
        var universeNavigation: UINavigationController = universeController.viewControllers?.first as UINavigationController
        
        
        let universe: UniverseController = universeNavigation.viewControllers[0] as UniverseController
        
        universe.fromConstellationFlag = 1
        universe.idForConstellationTransmissions = id
        universe.searchFlag = 2
        println("universeNavigation = \(universeNavigation.viewControllers[0])")
        universeController.selectedIndex = 0
        
        universeController.hidesBottomBarWhenPushed = false
        
        
        window?.rootViewController = universeController
        //        self.window?.rootViewController = universeController
        
        
    }

    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
}

