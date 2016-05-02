//
//  UniverseController.swift
//  NewUIYoumitter
//
//  Created by HOME on 20/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

let appearance = UITabBarItem.appearance()
let attributes = [NSFontAttributeName:UIFont(name: "Roboto", size: 20)]

class UniverseController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var universeTableView: UITableView!
    @IBOutlet var unreadMessageCount: UILabel!
    @IBOutlet var unreadAlertCount: UILabel!
    
    var currentPage: Int = 1
    var imageCache = [String : UIImage]()
    let kCellIdentifier: String = "UniverseImageCell"
    let cellIdentifier: String = "UniverseCell"
    var searchFlag = 0
    var tuneInTransmissionflag = 0
    var fromConstellationFlag = 0
    var searchData: String = "", searchLocation: String = "", searchCategory: String = ""
    var urlString: NSDictionary?
    var universeData: NSMutableArray = []
    var api: APIController?
    var apiKey :String = ""
    var refreshControl:UIRefreshControl!
    var constellations = NSMutableArray()
    var constellationIds = NSMutableArray()
    var constellationDetails = NSMutableArray()
    var alertNotification = NotificationCount()
    var idForConstellationTransmissions: Int = 0
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.universeTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        unreadMessageCount.layer.masksToBounds = true
        unreadAlertCount.layer.masksToBounds = true
        
        self.unreadAlertCount.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageCount.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        
//        if let tuneInFlagIsNotNil = defaults.objectForKey("tuneInTransmissionFlag") as? Int {
//            self.tuneInTransmissionflag = defaults.objectForKey("tuneInTransmissionFlag") as Int
//            var flag = 0
//            defaults.setObject(flag, forKey: "tuneInTransmissionFlag")
//
//        }
        
        if self.revealViewController() != nil {
            println("=======inside swreveal controller============")
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("=======no swrevealcontroller=================")
            
        }
        
    
//        var label = UILabel(frame: CGRectMake(0, 0, 5, 5))
//        label.center = CGPointMake(160, 284)
//        label.text = "5"
//        label.textAlignment = NSTextAlignment.Center
//        self.sideMenuButton.customView = label
        
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        println("=========== search flag =============== \(searchFlag)")
        println("=========== tune in transmission flag =========== \(tuneInTransmissionflag)")
//        self.sideMenuController()?.sideMenu?.delegate = self
//        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        
//if Reachability.isConnectedToNetwork() == true {
//            println("Internet connection OK")
//        
//        
        
        
        
        if self.searchFlag == 0 {
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                activityIndicatorView.startAnimating()
                api!.fetchTransmissions("universe",currentPage: 1)
                api!.delegate = self
                self.view.userInteractionEnabled = false
                self.refreshControl = UIRefreshControl()
                self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
                self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
                        
                self.universeTableView.addSubview(refreshControl)
            
                println("----------UniverseController----------")
            }
//            else {
//                println("No Internet connection")
//                let alertController = UIAlertController(title: "", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
//                
//                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//                    UIAlertAction in
//                    println("Ok Pressed")
//                    
//                    self.activityIndicatorView.stopAnimating()
//                    self.activityIndicatorView.hidden = true
//                    self.view.userInteractionEnabled = true
//                    
//                }
//                alertController.addAction(okAction)
//                self.presentViewController(alertController, animated: true, completion: nil)
//            }
        }
        else if searchFlag == 1{
        
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.searchTransmissions(searchData, searchLocation: searchLocation, searchCategory: searchCategory)
            }
        }
        else if tuneInTransmissionflag == 1 {
            println("from tune in transmission")
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchTuneInTransmissions()
            }
        }
        else if fromConstellationFlag == 1 {
            println("from constellation view========\(idForConstellationTransmissions)")
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchConstellationTransmissions(self.idForConstellationTransmissions)
            }
//            api!.fetchConstellationTransmissions(94)
        }
//}
//else {
//    println("Internet connection FAILED")
//    
//    let alertController = UIAlertController(title: "", message: "Make sure your device is connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
//    
//    var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
//        UIAlertAction in
//        println("Ok Pressed")
//        
//        self.activityIndicatorView.stopAnimating()
//        self.activityIndicatorView.hidden = true
//        self.view.userInteractionEnabled = true
//        
//    }
//    alertController.addAction(okAction)
//    self.presentViewController(alertController, animated: true, completion: nil)
//        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);

        self.navigationController?.setNavigationBarHidden(true, animated: true)
        

        self.universeTableView!.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(sender:AnyObject)
    {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            api!.fetchTransmissions("universe",currentPage: 1)
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
            self.refreshControl.endRefreshing()
        }
        // Code to refresh table view
    }
    
    func fetchConstellations() {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        println("=======in fetch constellations==========")
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
//                        self.constellationDetails.addObject(eachConstellation)
                        var constellationName: String = eachConstellation["name"] as String
                        var constellationId: Int = eachConstellation["id"] as Int
                        self.constellations.addObject(constellationName)
                        self.constellationIds.addObject(constellationId)
                        
                    }
                    
//                    if let userConstellationsNotNill = self.defaults.objectForKey("userConstellations") as? NSMutableArray {
                    
                        self.defaults.removeObjectForKey("userConstellations")
                        self.defaults.setObject(self.constellations, forKey: "userConstellations")
                        
//                    } else {
                    
//                        self.defaults.setObject(self.constellations, forKey: "userConstellations")
                    
//                    }
                    
//                    if let userConstellationIdsNotNill = self.defaults.objectForKey("userConstellationIds") as? NSMutableArray {
                    
                        self.defaults.removeObjectForKey("userConstellationIds")
                        self.defaults.setObject(self.constellationIds, forKey: "userConstellationIds")
                        
//                    } else {
                    
//                        self.defaults.setObject(self.constellationIds, forKey: "userConstellationIds")
                        //
//                    }
                    
                }
                    
                else {
                    self.constellations.addObject("No constellation found")
                    self.defaults.setObject(self.constellations, forKey: "userConstellations")
                    self.constellationIds.addObject("0")
                    self.defaults.setObject(self.constellationIds, forKey: "userConstellationIds")
                }
                
            } else {
                println(" === nil ==== ")
                // couldn't load JSON, look at error
            }
            
            
        })
            
        }
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return universeData.count
    }

    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell: UniverseCustomCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UniverseCustomCell
        if urlString == nil {
//            tableView.estimatedRowHeight = 133.00
            return 141.00
        }
        else {
//            tableView.estimatedRowHeight = 220.00
            return 220.00
        }
        
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        println("======== 123456 =========")
        
        //        self.universeTableView.backgroundView?.backgroundColor = UIColor(red: (230/255.0), green: (230/255.0), blue: (230/255.0), alpha:1.0)
        
        
        
        let rowData: NSDictionary = self.universeData[indexPath.row] as NSDictionary
        
        urlString = (rowData["photo"]?["photo"] as? NSDictionary)
        
        if urlString == nil {
            
            println("urlstring is nillllllllllllllll")
            
            var cell: UniverseWithoutImageTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UniverseWithoutImageTableViewCell
            
            cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
            
            
            cell.affirmButton.tag = rowData["id"] as Int
            
            
            var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("affirmButtonClicked:"))
            cell.affirmImageView.tag = rowData["id"] as Int
            cell.affirmImageView.addGestureRecognizer(tapGestureRecognizer)
            cell.affirmImageView.userInteractionEnabled = true
            
            cell.commentButton.tag = rowData["id"] as Int
            var row = indexPath.row
            if (row % 2 == 0) {
                cell.categoryImageView.backgroundColor = UIColor(red: (51/255.0), green: (153/255.0), blue: (255/255.0), alpha:1.0)
            }
            else {
                cell.categoryImageView.backgroundColor = UIColor(red: (102/255.0), green: (204/255.0), blue: (0/255.0), alpha:1.0)
            }
            cell.fromLabel.text = rowData["from_username"] as? String
            
            
            var transmissionConstellationsCountString: String = rowData["transmission_constellations_count"] as String
            var transmissionConstellationsCountInt = transmissionConstellationsCountString.toInt()
            
            if transmissionConstellationsCountInt > 1 {
                
                println("greater than zero")
                cell.toLabel.text = "\(transmissionConstellationsCountInt!) Constellations"
                
            }
            else {
                println("not greater than zero")
                cell.toLabel.text = rowData["to_username"] as? String
            }
            
            
            cell.bodyLabel.text = rowData["body"] as? String
            
            cell.timeLabel.text = rowData["created_at"] as? String
            
            var commentCount = rowData["comment_count"] as? Int
            if commentCount != 0 {
                cell.commentButton.setTitle(" Comment(\(commentCount!))", forState: UIControlState.Normal)
            }
            else {
                cell.commentButton.setTitle(" Comment(0)", forState: UIControlState.Normal)
            }
            //                cell.textLabel.text = rowData["body"] as? String
            
            
            let categoryId: Int = rowData["category_id"] as Int
            // Category image fetching end
            let categoryImageString = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(categoryId).png"
            
            println("categoryimageString ====== \(categoryImageString)")
            
            //Image caching
            
            var image = self.imageCache[categoryImageString]
            
            if (image == nil) {
                println("image is nilllllll")
                var categoryImageUrl: NSURL? = NSURL(string: categoryImageString)
                var imgURL: NSURL = NSURL(string: categoryImageString)!
                
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: imgURL)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        image = UIImage(data: data)
                        
                        // Store the image in to our cache
                        self.imageCache[categoryImageString] = image
                        dispatch_async(dispatch_get_main_queue(), {
                            //                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            //                            cellToUpdate.categoryImageView?.image = image
                            //                        }
                            
//                            cell.categoryImageView.contentMode = .ScaleAspectFit
//                            cell.categoryImageView.contentMode = .ScaleCenter
//                            if (cell.categoryImageView.bounds.size.width > image?.size.width && cell.categoryImageView.bounds.size.height > image?.size.height) {
//                                cell.categoryImageView.contentMode = .ScaleAspectFit
//                            }
                            cell.categoryImageView.image = image
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
            }
            else {
                println("image is not nillllllll")
                dispatch_async(dispatch_get_main_queue(), {
                    //                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    //                    cellToUpdate.categoryImageView?.image = image
                    //                }
//                    if (cell.categoryImageView.bounds.size.width > image?.size.width && cell.categoryImageView.bounds.size.height > image?.size.height) {
//                        cell.categoryImageView.contentMode = .ScaleAspectFit
//                    }
                    cell.categoryImageView.image = image
                })
            }
            
         
            return cell
        }
        else {
            println("urlstring is not nilllllllllllll")
        var cell: UniverseCustomCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as UniverseCustomCell
        
        
            
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
            
        cell.affirmButton.tag = rowData["id"] as Int
        
            
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("affirmButtonClicked:"))
        cell.affirmImageView.tag = rowData["id"] as Int
        cell.affirmImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.affirmImageView.userInteractionEnabled = true
            
        cell.commentButton.tag = rowData["id"] as Int
        var row = indexPath.row
        if (row % 2 == 0) {
            cell.categoryImageView.backgroundColor = UIColor(red: (51/255.0), green: (153/255.0), blue: (255/255.0), alpha:1.0)
        }
        else {
            cell.categoryImageView.backgroundColor = UIColor(red: (102/255.0), green: (204/255.0), blue: (0/255.0), alpha:1.0)
        }
        cell.fromLabel.text = rowData["from_username"] as? String
        
        
        var transmissionConstellationsCountString: String = rowData["transmission_constellations_count"] as String
        var transmissionConstellationsCountInt = transmissionConstellationsCountString.toInt()
        
        if transmissionConstellationsCountInt > 0 {
            
            println("greater than zero")
            cell.toLabel.text = "\(transmissionConstellationsCountInt!) Constellations"
    
        }
        else {
            println("not greater than zero")
            cell.toLabel.text = rowData["to_username"] as? String
        }
        
        
        cell.bodyLabel.text = rowData["body"] as? String
        
        cell.timeLabel.text = rowData["created_at"] as? String
        
        var commentCount = rowData["comment_count"] as? Int
        if commentCount != 0 {
            cell.commentButton.setTitle(" Comment(\(commentCount!))", forState: UIControlState.Normal)
        }
        else {
            cell.commentButton.setTitle(" Comment(0)", forState: UIControlState.Normal)
        }
        //                cell.textLabel.text = rowData["body"] as? String
        urlString = (rowData["photo"]?["photo"] as? NSDictionary)
        
        cell.transmissionImage.contentMode = UIViewContentMode.ScaleAspectFill
        cell.transmissionImage.clipsToBounds = true
        
        // Category image fetching start
        let categoryId: Int = rowData["category_id"] as Int
        // Category image fetching end
        let categoryImageString = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(categoryId).png"
        
        //Image caching
        
        var image = self.imageCache[categoryImageString]
        if (urlString != nil) {
            cell.transmissionImage.hidden = false
            cell.heightConstraintForTransmissionImage.constant = 87.0
            
            let urlForImage:NSString = urlString?.valueForKey("url") as NSString
            var transImage = self.imageCache[urlForImage]
            
            
            if (transImage == nil) {
               
                var transImgURL: NSURL = NSURL(string: urlForImage)!
                
                let request: NSURLRequest = NSURLRequest(URL: transImgURL)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        transImage = UIImage(data: data)
                        
//                        self.imageCache[categoryImageString] = image
                        dispatch_async(dispatch_get_main_queue(), {
                            //                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            //                            cellToUpdate.categoryImageView?.image = image
                            //                        }
                            cell.transmissionImage.image = transImage
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
               
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    //                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    //                    cellToUpdate.categoryImageView?.image = image
                    //                }
//                    cell.transmissionImage.image = image
                    cell.transmissionImage.image = transImage
                })
            }
        }
        else {
            cell.transmissionImage.hidden = true
            cell.heightConstraintForTransmissionImage.constant = 0.0
            //            cell.transmissionImage.image = UIImage(named: "tempimage.png")
        }
        
        if (image == nil) {
            var categoryImageUrl: NSURL? = NSURL(string: categoryImageString)
            var imgURL: NSURL = NSURL(string: categoryImageString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[categoryImageString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        //                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                        //                            cellToUpdate.categoryImageView?.image = image
                        //                        }
                        
//                        if (cell.categoryImageView.bounds.size.width > image?.size.width && cell.categoryImageView.bounds.size.height > image?.size.height) {
//                            cell.categoryImageView.contentMode = .ScaleAspectFit
//                        }
                        cell.categoryImageView.image = image
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                //                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                //                    cellToUpdate.categoryImageView?.image = image
                //                }
                cell.categoryImageView.image = image
            })
        }
        
        
        if (urlString != nil) {
            
            let urlForImage:NSString = urlString?.valueForKey("url") as NSString
            
            let imgURL: NSURL? = NSURL(string: urlForImage)
            
            //                  Download an NSData representation of the image at the URL
            //                    let imgData = NSData(contentsOfURL: imgURL!)
            //                    cell.imageView.image = UIImage(data: imgData!)
            //                    cell.transmissionImage.image = UIImage(data: imgData!)
            
        }
        //         Youmitter code
        return cell
        }
        
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//
//        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as UniverseCustomCell
//    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      
        var row = indexPath.row
        //        prinltn("displaying content = \(universeData)")
        //        if searchFlag == 0 {
        if row == universeData.count-1 {
            self.currentPage += 1
           
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchTransmissions("universe",currentPage: currentPage)
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
            }
            
        }
        else {
            
        }
        //        }
    }
    
    func imageTapped() {
        
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        
        if results.objectForKey("transmissions") != nil {
            if searchFlag == 0 {
                var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var messageCount:Int = results.objectForKey("unread_message_count") as Int
                var alertCount:Int = results.objectForKey("unread_alert_count") as Int
                var defaultUserName: String = results.objectForKey("default_username") as String
                
                println("default username ==== \(defaultUserName)")
                
                defaults.setObject(messageCount, forKey: "unreadMessageCount")
                defaults.setObject(alertCount, forKey: "unreadAlertCount")
                defaults.setObject(defaultUserName, forKey: "defaultUserName")
                
                var alertNotification = NotificationCount()
                self.unreadAlertCount.text = " \(alertNotification.unreadAlertCount) "
                self.unreadMessageCount.text = " \(alertNotification.unreadMessageCount) "
                self.unreadAlertCount.hidden = alertNotification.checkForAlertCount()
                self.unreadMessageCount.hidden = alertNotification.checkForMessageCount()
            }
            
            var resultsArr: NSMutableArray = results["transmissions"] as NSMutableArray
            dispatch_async(dispatch_get_main_queue(), {
                self.fetchConstellations()
                if self.currentPage == 1 {
                    self.universeData = resultsArr
                    self.universeTableView!.reloadData()
                }
                else {
                    //                    self.universeData.append(resultsArr)
                    self.universeData.addObjectsFromArray(resultsArr.subarrayWithRange(NSMakeRange(0, resultsArr.count)))
                    self.universeTableView!.reloadData()
                }
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            })
        }
        else if (results.objectForKey("result") != nil) {
            if universeData.count == 0 {
                var result: String = results["result"] as String
                let alertController = UIAlertController(title: "", message: "\(result)", preferredStyle: UIAlertControllerStyle.Alert)
            
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
            else {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        }
        else if ((results.objectForKey("error") != nil)) {
            if universeData.count == 0 {
                if fromConstellationFlag == 1 {
                    let alertController = UIAlertController(title: "", message: "Transmissions not found.", preferredStyle: UIAlertControllerStyle.Alert)
                    
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
                else {
                    var result: String = results["error"] as String
                
                    let alertController = UIAlertController(title: "", message: "\(result)", preferredStyle: UIAlertControllerStyle.Alert)
            
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
            else {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        }
        else {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.view.userInteractionEnabled = true
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            var detailsViewController: TransmissionDetailsViewController = segue.destinationViewController as TransmissionDetailsViewController
            var transmissionIndex = self.universeTableView.indexPathForSelectedRow()!
            
            detailsViewController.transmissionDetails = self.universeData.objectAtIndex(transmissionIndex.row) as NSDictionary
            detailsViewController.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier!.rangeOfString("newTransmission") != nil {
            
            var newTransmissionViewController: NewTransmissionViewController = segue.destinationViewController as NewTransmissionViewController
            newTransmissionViewController.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier == "toComments" {
            
            var commentsConroller: CommentsViewController = segue.destinationViewController as CommentsViewController
            commentsConroller.transmissionId = sender!.tag
            commentsConroller.hidesBottomBarWhenPushed = true
        }
    }
    
    
    @IBAction func affirmButtonClicked(sender: AnyObject) {
        
        var transmissionId = 0
        
        if (sender.tag == nil) {
            transmissionId = (sender.view?.tag)!
        }
        else {
            transmissionId = sender.tag
        }
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        self.activityIndicatorView.hidden = false
        activityIndicatorView.startAnimating()
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/affirm.json?api_key=\(apiKey)&transmission_id=\(transmissionId)"
        println("url======\(url)")
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("message") != nil {
                    var message :NSString? = jsonResult?.valueForKey("message") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Transmission has been affirmed, Thank You.", preferredStyle: UIAlertControllerStyle.Alert)
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
                    
                    
                    
                    
                    //
                }
                else {
                    var errorMessage :NSString? = jsonResult?.valueForKey("affirm") as? NSString
                    if (errorMessage == nil) {
                        errorMessage = "Transmission cannot be affirmed."
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage!)", preferredStyle: UIAlertControllerStyle.Alert)
                        
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
        else {
//            Reachability.displayAlert(self)
        }
        
    }
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    
    @IBAction func sideMenuClicked(sender: AnyObject) {
        toggleSideMenuView()
//        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//        appDelegate.logOutButtonClicked()
        
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
    // MARK: - ENSideMenu Delegate
    
    @IBAction func searchMenuClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true

        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
        unreadMessageCount.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
        unreadAlertCount.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }
    
    
 
    
    
}
