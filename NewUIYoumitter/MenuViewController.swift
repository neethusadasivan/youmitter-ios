//
//  MenuViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 24/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet var menuTableView: UITableView!
    @IBOutlet var heightOfTableView: NSLayoutConstraint!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    var selectedMenuItem : Int = 0
    var menus: [[String]] = [["Add New"], [], ["Tune In Transmissions"], ["App Settings", "Profile Settings"], ["Logout"]]
    var sections = ["Constellations", "See All", "", "Settings", ""]
    var data : [[String]] = [["Mike", "John", "Jane"], ["Phil", "Tania", "Monica"]]
    var seeAllFlag = false
    
    var sectionTitleArray : NSMutableArray = NSMutableArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var userConstellations: NSMutableArray = NSMutableArray()
    var userConstellationIds: NSMutableArray = NSMutableArray()
    var userConstellationDetails: NSMutableArray = NSMutableArray()
    var threeConstellations: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("Self.userConstellationDetails ======= \(self.userConstellationDetails)")
        menuTableView.backgroundColor = UIColor(red: (102/255.0), green: (102/255.0), blue: (102/255.0), alpha:1.0)
        
        if let userConstellationsIsNotNill = defaults.objectForKey("userConstellations") as? NSMutableArray {
            self.userConstellations = defaults.objectForKey("userConstellations") as NSMutableArray
            if self.userConstellations[0] as String == "No constellation found" {
//                menuTableView.hidden = true
                heightOfTableView.constant = 0.0
            }
            if let userConstellationIdsIsNotNill = defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                self.userConstellationIds = defaults.objectForKey("userConstellationIds") as NSMutableArray
            }
        }
        else {
            self.userConstellations = ["No constellation found"]
            
        }
        
        
        if let userNameIsNotNill = defaults.objectForKey("userName") as? NSString {
            self.userNameLabel.text = defaults.objectForKey("userName") as NSString
        }
        
        

        //        menus.insert(self.userConstellations, atIndex: 0)
        // Customize apperance of table view
        self.threeConstellations.addObject("Add New")
        println("======self.userConstellations.count===== \(self.userConstellations.count)")
        if self.userConstellations.count >= 3 {
            println("=====self.userconstellation greater than or equal to 3=====")
            for i in 1...3 {
                self.threeConstellations.addObject(self.userConstellations[i])
            }
        }
        else {
            println("=====self.userconstellation less than or equal to 3=====")
        }

        var userImageString = ""
        if let userImageIsNotNill = defaults.objectForKey("imageUrl") as? NSString {
            userImageString = defaults.objectForKey("imageUrl") as NSString
        }
        println("userImageString ===== \(userImageString)")
        let imgURL: NSURL = NSURL(string: userImageString)!
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

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize = CGSize(width:10, height:570)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.menuTableView.flashScrollIndicators()
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        var userImageString = ""
//        if let userImageIsNotNill = defaults.objectForKey("ImageUrl") as? NSString {
//            userImageString = defaults.objectForKey("imageUrl") as NSString
//        }
//        let imgURL: NSURL = NSURL(string: userImageString)!
//        //        let imgData = NSData(contentsOfURL: imgURL)
//        //        if imgData != nil {
//        //            categoryImageView.image = UIImage(data :imgData!)
//        //        }
//        //
//        //        var transImgURL: NSURL = NSURL(string: urlForImage)!
//        //
//        let request: NSURLRequest = NSURLRequest(URL: imgURL)
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//            if error == nil {
//                var userImage = UIImage(data: data)
//                
//                // Store the image in to our cache
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    self.userImageView.image = userImage
//                })
//            }
//            else {
//                println("Error: \(error.localizedDescription)")
//            }
//        })
//        
//        
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        
        return self.sections.count
        
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int {
    
        var count = 0
        if section == 0 {
            if seeAllFlag == false {
                count = self.userConstellations.count
            }
            else if seeAllFlag == true {
                count = menus[section].count
            }
        }
        else if section == 1 {
            if seeAllFlag == false {
                count = menus[section].count
            }
            else if seeAllFlag == true {
                count = self.userConstellations.count
            }
        }
        return count
        
    }

//    func tableView( tableView : UITableView,  titleForHeaderInSection section: Int)->String
//    {
//        if self.userConstellations.count > 3 {
//            return "My Constellations"
//        }
//        else {
//            return ""
//        }
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        cell?.backgroundColor = UIColor(red: (102/255.0), green: (102/255.0), blue: (102/255.0), alpha:1.0)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel.textColor = UIColor.grayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        let name = self.userConstellations[indexPath.row] as String
        
//        var eachConstellation = self.userConstellationDetails[indexPath.row]
        
        cell!.textLabel.text = name
        cell!.tag = indexPath.row

        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
//        if segue.identifier == "toMyConstellations" {
//            let nav = segue.destinationViewController as UINavigationController
//            let constellationViewController = nav.topViewController as MyConstellationsViewController
//            //            var constellationViewController: MyConstellationsViewController = segue.destinationViewController as MyConstellationsViewController
//            //            var constellationIndex = self.menuTableView!.indexPathForSelectedRow()!
//            
//            //            constellationViewController.constellationDetails = self.userConstellationDetails.objectAtIndex(sender!.tag) as? NSDictionary
//            constellationViewController.constellationId = self.userConstellationIds[sender!.tag] as? Int
//            constellationViewController.constellationName = self.userConstellations[sender!.tag] as? String
//        }
        
        
        
        if segue.identifier == "toMyConstellations" {
          
            var id = self.userConstellationIds[sender!.tag] as? Int
            var name = self.userConstellations[sender!.tag] as? String
            defaults.setObject(id!, forKey: "selectedConstellatonId")
            defaults.setObject(name!, forKey: "selectedConstellatonName")
            
        }
        
        else if segue.identifier == "toBlog" {
//            let nav = segue.destinationViewController as UINavigationController
//            let blogHelpViewController = nav.topViewController as BlogAndHelpViewController
            let blogHelpViewController = segue.destinationViewController as BlogAndHelpViewController
            blogHelpViewController.url = "http://\(GlobalVariable.apiUrl)/blog"
        }
        else if segue.identifier == "toHelp" {
//            let nav = segue.destinationViewController as UINavigationController
//            let blogHelpViewController = nav.topViewController as BlogAndHelpViewController
            let blogHelpViewController = segue.destinationViewController as BlogAndHelpViewController

            blogHelpViewController.url = "http://\(GlobalVariable.apiUrl)/help"
        }
    }
   
    @IBAction func tuneInTransmissionsClicked(sender: AnyObject) {
        
//        var flag = 1
//        defaults.setObject(flag, forKey: "tuneInTransmissionFlag")
//        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.toUniverseController()
        
    }
    
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.logOutButtonClicked()
        
    }
    

}
