//
//  YouController.swift
//  NewUIYoumitter
//
//  Created by HOME on 20/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class YouController: UIViewController, APIControllerProtocol, ENSideMenuDelegate  {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var youTableView: UITableView!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    
    var youData: NSMutableArray = []
    var currentPage: Int = 1
    var api: APIController?
    var apiKey: String = ""
    var durationIds = ["1", "2", "3", "4", "5"]
    var durations = ["1 Day", "3 Days", "1 Week", "2 Weeks", "1 Month"]
    var selectedDuration: String = ""
    var selectedDurationId: String = ""
    let kCellIdentifier: String = "YouImageCell"
    let cellIdentifier: String = "YouCell"
    var imageCache = [String : UIImage]()
    var urlString: NSDictionary?
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.youTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        self.unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        api = APIController(delegate: self)
        
        self.view.userInteractionEnabled = false
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        self.refreshControl.addTarget(self, action: "refreshYou:", forControlEvents: UIControlEvents.ValueChanged)
        self.youTableView.addSubview(refreshControl)
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            activityIndicatorView.startAnimating()
            api!.fetchTransmissions("own",currentPage: 0)
        }
        api!.delegate = self
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        println("----------YouController----------")
        
    }

    func refreshYou(sender:AnyObject)
    {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            println("pull to refresh working")
            api!.fetchTransmissions("own",currentPage: 1)
            self.activityIndicatorView.startAnimating()
            self.activityIndicatorView.hidden = false
            self.view.userInteractionEnabled = false
            self.refreshControl.endRefreshing()
        }
        // Code to refresh table view
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        self.tabBarController?.tabBar.hidden = false
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.youTableView!.reloadData()
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return youData.count
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell: YouCustomTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as YouCustomTableViewCell
        if urlString == nil {
//            tableView.estimatedRowHeight = 98.00
            return 105.00
        }
        else {
//            tableView.estimatedRowHeight = 220.00
            return 220.00
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        var row = indexPath.row
        //        prinltn("displaying content = \(universeData)")
        if row == youData.count-1 {
            self.currentPage += 1
            println("Reaches end")
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchTransmissions("own",currentPage: currentPage)
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
            }
        }
        else {
            println("row = \(row)")
            
        }
    }
    
    func checkTime(createdDate: String) -> Int {
        
        println("Date ====  \(createdDate)")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss ZZZ"
        let createdDateTime = dateFormatter.dateFromString(createdDate + " +0000")
        println("====== createdDateTime ======= \(createdDateTime!)")
        
        let nowDate = NSDate()
        // "Jul 23, 2014, 11:01 AM" <-- looks local without seconds. But:
        println("===nowDate === \(nowDate)")
        var formatter = NSDateFormatter()
        
        
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        
        
        let defaultTimeZoneStr = formatter.stringFromDate(nowDate);
        // "2014-07-23 11:01:35 -0700" <-- same date, local, but with seconds
        formatter.timeZone = NSTimeZone(abbreviation: "UTC");
        

        let nowDateUTC = formatter.stringFromDate(nowDate)
        // "2014-07-23 18:01:41 +0000" <-- same date, now in UTC
        println("utcTimeZoneStr======\(nowDateUTC)")
        

        let elapsedTime = NSDate().timeIntervalSinceDate(createdDateTime!)
        println("====elapsed time======\(Int(elapsedTime)/60)")
        var timeDiff: Int = Int(elapsedTime)/60
        return timeDiff
        
    }
    
    func editTransmissionButtonTapped(rowData: NSDictionary) {
        //Goto new transmission page
        //Set the editFlag in new transmission page to 1
        //Pass the rowData
    }
    
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let rowData: NSDictionary = self.youData[indexPath.row] as NSDictionary
        
        urlString = (rowData["photo"]?["photo"] as? NSDictionary)
        
        if urlString != nil {
        
            println("urlstring is not nillllllllllllllll")
            
        let cell: YouCustomTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as YouCustomTableViewCell
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
            
        cell.editButton.hidden = true
            
        //Time checking
            
        var timeDiff: Int = checkTime(rowData["created_at"] as String)
        if (timeDiff < 16) {
            cell.editButton.hidden = false
        }
        else {
            cell.editButton.hidden = true
        }
            
        //Time checking
        cell.editButton.tag = indexPath.row as Int
//        cell.stopTitleButton.tag = rowData["id"] as Int
        cell.stopTitleButton.tag = indexPath.row as Int
        
//        cell.retransmitTitleButton.tag = rowData["id"] as Int
        cell.retransmitTitleButton.tag = indexPath.row as Int
        
//        cell.deleteButton.tag = rowData["id"] as Int
        cell.deleteButton.tag = indexPath.row as Int
        
//        cell.overFlowButton.tag = rowData["id"] as Int
        cell.overFlowButton.tag = indexPath.row as Int
        
        //        cell.textLabel.text = rowData["trackName"] as? String
        
        // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
        //        let urlString: NSString = rowData["artworkUrl60"] as NSString
        //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
        
        //        let imgURL: NSURL? = NSURL(string: urlString)
        //        let imgData = NSData(contentsOfURL: imgURL!)
        //        cell.imageView.image = UIImage(data: imgData!)
        //        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
        
        //        cell.detailTextLabel?.text = formattedPrice
        
        
        //         Youmitter code
        
        cell.bodyLabel.text = rowData["body"] as? String
        cell.detailTextLabel?.text = rowData["created_at"] as? String
        
        var transmissionStatus = rowData["status"] as? String
        if transmissionStatus == "running" {
            println("running")
            cell.retransmitTitleButton.userInteractionEnabled = false
            var retransmitImage = UIImage(named: "retransmit_btn") as UIImage?
            let tintedRetransmitImage = retransmitImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.retransmitTitleButton.setImage(tintedRetransmitImage, forState: UIControlState.Normal)
            cell.retransmitTitleButton.tintColor = UIColor.grayColor()
            
            var stopImage = UIImage(named: "stop_btn") as UIImage?
            let tintedStopImage = stopImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.stopTitleButton.setImage(tintedStopImage, forState: UIControlState.Normal)
            
            cell.stopTitleButton.setTitle(" Stop", forState: UIControlState.Normal)
            cell.stopTitleButton.tintColor = UIColor.redColor()
            
            cell.stopTitleButton.userInteractionEnabled = true
            
            cell.overFlowButton.hidden = false
            cell.widthForOverFlowButton.constant = 30.00
            //            let resumeImage = UIImage(named: "ic_action_resume.png") as UIImage?
            //            cell.stopTitleButton.setTitle("Resume", forState: UIControlState.Normal)
            //            cell.stopImageButton.setImage(resumeImage, forState: .Normal)
            //            cell.retransmitTitleButton.setTitle("Resume", forState: UIControlState.Normal)
            //
            
        }
        else if transmissionStatus == "expired" {
            println("expired")
            var resumeImage = UIImage(named: "play_btn") as UIImage?
            
//            let origImage = UIImage(named: "imageName");
            let tintedResumeImage = resumeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//            btn.setImage(tintedImage, forState: .Normal)
//            btn.tintColor = UIColor.redColor(
            
            cell.stopTitleButton.setImage(tintedResumeImage, forState: UIControlState.Normal)
            cell.stopTitleButton.tintColor = UIColor.grayColor()
            
            cell.stopTitleButton.setTitle(" Resume", forState: UIControlState.Normal)
            
            cell.stopTitleButton.userInteractionEnabled = false
            
            cell.retransmitTitleButton.userInteractionEnabled = true
            
            var retransmitImage = UIImage(named: "retransmit_btn") as UIImage?
            let tintedRetransmitImage = retransmitImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            cell.retransmitTitleButton.setImage(tintedRetransmitImage, forState: UIControlState.Normal)
            cell.retransmitTitleButton.tintColor = UIColor.blueColor()
            
            cell.overFlowButton.hidden = true
            cell.widthForOverFlowButton.constant = 0.00
            
        }
        else if transmissionStatus == "stopped" {
            
            println("stopped")
            var resumeImage = UIImage(named: "play_btn") as UIImage?
            let tintedResumeImage = resumeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            cell.stopTitleButton.setImage(tintedResumeImage, forState: UIControlState.Normal)
//            cell.stopTitleButton.tintColor = UIColor.greenColor()
            cell.stopTitleButton.tintColor = UIColor.greenColor()
            cell.stopTitleButton.tintColor = UIColor(netHex:0x24BF1E)
            
            cell.stopTitleButton.setTitle(" Resume", forState: UIControlState.Normal)
            //            cell.stopTitleButton.tintColor = UIColor.greenColor()
            cell.stopTitleButton.userInteractionEnabled = true
            
            cell.overFlowButton.hidden = true
            cell.widthForOverFlowButton.constant = 0.00
            
            cell.retransmitTitleButton.userInteractionEnabled = false
        }
        
        cell.transmissionImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.transmissionImageView.clipsToBounds = true
        
        if (urlString != nil) {
            cell.transmissionImageView.hidden = false
            cell.heightConstraintForTransmissionImage.constant = 120.0
            
            let urlForImage:NSString = urlString?.valueForKey("url") as NSString
//            var transImage = self.imageCache[urlForImage]
            
            
                var transImgURL: NSURL = NSURL(string: urlForImage)!
                println("========transImgURL===========\(transImgURL)")
            println("========urlString===========\(urlString)")
            
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: transImgURL)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        var transImage = UIImage(data: data)
                        
                        // Store the image in to our cache
                        //                        self.imageCache[urlString] = transImage
                        dispatch_async(dispatch_get_main_queue(), {
                            //                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            //                            cellToUpdate.categoryImageView?.image = image
                            //                        }
                            cell.transmissionImageView.image = transImage
                        })
                    }
                    else {
                        println("Error: \(error.localizedDescription)")
                    }
                })
                
            
            
            
////image caching
            
//            
//            //                  Download an NSData representation of the image at the URL
//            //            let imgData = NSData(contentsOfURL: imgURL!)
//            //                    cell.imageView.image = UIImage(data: imgData!)
//            //            cell.transmissionImage.image = UIImage(data: imgData!)
//            
//            if (transImage == nil) {
//                //                var categoryImageUrl: NSURL? = NSURL(string: categoryImageString)
//                var transImgURL: NSURL = NSURL(string: urlForImage)!
//                
//                // Download an NSData representation of the image at the URL
//                let request: NSURLRequest = NSURLRequest(URL: transImgURL)
//                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
//                    if error == nil {
//                        transImage = UIImage(data: data)
//                        
//                        // Store the image in to our cache
//                        //                        self.imageCache[urlString] = transImage
//                        dispatch_async(dispatch_get_main_queue(), {
//                            //                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                            //                            cellToUpdate.categoryImageView?.image = image
//                            //                        }
//                            cell.transmissionImageView.image = transImage
//                        })
//                    }
//                    else {
//                        println("Error: \(error.localizedDescription)")
//                    }
//                })
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), {
//                    //                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
//                    //                    cellToUpdate.categoryImageView?.image = image
//                    //                }
//                    cell.transmissionImageView.image = transImage
//                })
//            }
            
////image caching
        }
        else {
            cell.transmissionImageView.hidden = true
            cell.heightConstraintForTransmissionImage.constant = 0.0
            //            cell.transmissionImage.image = UIImage(named: "tempimage.png")
        }
        //         Youmitter code
        
        
        
        return cell
            
        }
        else {
            
            println("urlstring is nil")
            
            let cell: YouWithoutImageCustomCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as YouWithoutImageCustomCell
            
            cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
            //Time checking
            
            var timeDiff: Int = checkTime(rowData["created_at"] as String)
            if (timeDiff < 16) {
                cell.editButton.hidden = false
            }
            else {
                cell.editButton.hidden = true
            }
            
            //Time checking
            
            let rowData: NSDictionary = self.youData[indexPath.row] as NSDictionary
            
            cell.editButton.tag = indexPath.row as Int
            //        cell.stopTitleButton.tag = rowData["id"] as Int
            cell.stopTitleButton.tag = indexPath.row as Int
            
            //        cell.retransmitTitleButton.tag = rowData["id"] as Int
            cell.retransmitTitleButton.tag = indexPath.row as Int
            
            //        cell.deleteButton.tag = rowData["id"] as Int
            cell.deleteButton.tag = indexPath.row as Int
            
            //        cell.overFlowButton.tag = rowData["id"] as Int
            cell.overFlowButton.tag = indexPath.row as Int
            
            //        cell.textLabel.text = rowData["trackName"] as? String
            
            // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
            //        let urlString: NSString = rowData["artworkUrl60"] as NSString
            //        let urlString: NSDictionary = rowData?["photo"] as NSDictionary
            
            //        let imgURL: NSURL? = NSURL(string: urlString)
            //        let imgData = NSData(contentsOfURL: imgURL!)
            //        cell.imageView.image = UIImage(data: imgData!)
            //        let formattedPrice: NSString = rowData["formattedPrice"] as NSString
            
            //        cell.detailTextLabel?.text = formattedPrice
            
            
            //         Youmitter code
            
            cell.bodyLabel.text = rowData["body"] as? String
            cell.detailTextLabel?.text = rowData["created_at"] as? String
            
            var transmissionStatus = rowData["status"] as? String
            if transmissionStatus == "running" {
                println("running")
                cell.retransmitTitleButton.userInteractionEnabled = false
                var retransmitImage = UIImage(named: "retransmit_btn") as UIImage?
                let tintedRetransmitImage = retransmitImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.retransmitTitleButton.setImage(tintedRetransmitImage, forState: UIControlState.Normal)
                cell.retransmitTitleButton.tintColor = UIColor.grayColor()
                
                var stopImage = UIImage(named: "stop_btn") as UIImage?
                let tintedStopImage = stopImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.stopTitleButton.setImage(tintedStopImage, forState: UIControlState.Normal)
                
                cell.stopTitleButton.setTitle(" Stop", forState: UIControlState.Normal)
                cell.stopTitleButton.tintColor = UIColor.redColor()
                
                cell.stopTitleButton.userInteractionEnabled = true
                
                cell.overFlowButton.hidden = false
                cell.widthForOverFlowButton.constant = 30.00
                //            let resumeImage = UIImage(named: "ic_action_resume.png") as UIImage?
                //            cell.stopTitleButton.setTitle("Resume", forState: UIControlState.Normal)
                //            cell.stopImageButton.setImage(resumeImage, forState: .Normal)
                //            cell.retransmitTitleButton.setTitle("Resume", forState: UIControlState.Normal)
                //
                
            }
            else if transmissionStatus == "expired" {
                println("expired")
                var resumeImage = UIImage(named: "play_btn") as UIImage?
                
                //            let origImage = UIImage(named: "imageName");
                let tintedResumeImage = resumeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                //            btn.setImage(tintedImage, forState: .Normal)
                //            btn.tintColor = UIColor.redColor(
                
                cell.stopTitleButton.setImage(tintedResumeImage, forState: UIControlState.Normal)
                cell.stopTitleButton.tintColor = UIColor.grayColor()
                
                cell.stopTitleButton.setTitle(" Resume", forState: UIControlState.Normal)
                
                cell.stopTitleButton.userInteractionEnabled = false
                
                cell.retransmitTitleButton.userInteractionEnabled = true
                
                var retransmitImage = UIImage(named: "retransmit_btn") as UIImage?
                let tintedRetransmitImage = retransmitImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.retransmitTitleButton.setImage(tintedRetransmitImage, forState: UIControlState.Normal)
                cell.retransmitTitleButton.tintColor = UIColor.blueColor()
                
                cell.overFlowButton.hidden = true
                cell.widthForOverFlowButton.constant = 0.00
                
            }
            else if transmissionStatus == "stopped" {
                
                println("stopped")
                var resumeImage = UIImage(named: "play_btn") as UIImage?
                let tintedResumeImage = resumeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                
                cell.stopTitleButton.setImage(tintedResumeImage, forState: UIControlState.Normal)
                //            cell.stopTitleButton.tintColor = UIColor.greenColor()
                cell.stopTitleButton.tintColor = UIColor.greenColor()
                cell.stopTitleButton.tintColor = UIColor(netHex:0x24BF1E)
                
                cell.stopTitleButton.setTitle(" Resume", forState: UIControlState.Normal)
                //            cell.stopTitleButton.tintColor = UIColor.greenColor()
                cell.stopTitleButton.userInteractionEnabled = true
                
                cell.overFlowButton.hidden = true
                cell.widthForOverFlowButton.constant = 0.00
                
                cell.retransmitTitleButton.userInteractionEnabled = false
            }
            
            
            //         Youmitter code
            
            
            
            return cell
            
            
        }
    }
    
    @IBAction func overFlowButtonClicked(sender: AnyObject) {
        
        println("overflow button clicked")
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        
        var alertController = UIAlertController(title: "", message: "Select Duration", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.durations.count {
            var okAction = UIAlertAction(title: "\(self.durations[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                self.selectedDuration = self.durations[i]
                self.selectedDurationId = self.durationIds[i]
                self.extendTransmission(sender.tag)
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.view.userInteractionEnabled = true
            
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
   
    func extendTransmission(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var transmissionData: NSDictionary = youData[id] as NSDictionary
        var transmissionId: Int = transmissionData["id"] as Int
        var archived: String = transmissionData["archived"] as String
        
        var url = "http://\(GlobalVariable.apiUrl)/api/transmissions/extend_transmission.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&preset_duration_id=\(self.selectedDurationId)&archived=\(archived)"
        
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("notification") != nil {
                    var message :NSString? = jsonResult?.valueForKey("notification") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Your transmission has been extended.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                                self.currentPage = 0
                                self.api!.fetchTransmissions("own", currentPage: self.currentPage)
                            }
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("error") != nil {
                    
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Transmission cannot be extended.", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                
                // couldn't load JSON, look at error
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
                
            }
            
            
        })
            
        }
    }
    
    
    @IBAction func editButtonClicked(sender: AnyObject) {
        
//        var transmissionData: NSDictionary = youData[sender.tag] as NSDictionary
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var newTransmissionViewController: NewTransmissionViewController = mainStoryboard.instantiateViewControllerWithIdentifier("newTransmissionViewController") as NewTransmissionViewController
////        newTransmissionViewController.hidesBottomBarWhenPushed = true
//        newTransmissionViewController.editFlag = 1
//        newTransmissionViewController.transmissionDetails = transmissionData
////        navigationController?.pushViewController(newTransmissionViewController, animated: true)
//        self.presentViewController(newTransmissionViewController, animated: true, completion: nil)
        
    }
    
    

    @IBAction func stopButtonClicked(sender: AnyObject) {
        
        println("stop button clicked")
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var title = sender.titleForState(.Normal)
        
        var transmissionData: NSDictionary = youData[sender.tag] as NSDictionary
        var transmissionId: Int = transmissionData["id"] as Int
        var archived: String = transmissionData["archived"] as String
        
        var url : String = ""
        if title == " Stop" {
            url = "http://\(GlobalVariable.apiUrl)/api/transmissions/stop_transmission.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&archived=\(archived)"
        }
        else if title == " Resume" {
            url = "http://\(GlobalVariable.apiUrl)/api/transmissions/resume_transmission.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&archived=\(archived)"
        }
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("transmission") != nil {
                    var message :NSString? = jsonResult?.valueForKey("transmission") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Transmission \(message!)", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                                self.currentPage = 0
                                self.api!.fetchTransmissions("own", currentPage: self.currentPage)
                            }
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("error") != nil {
                    
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Transmission cannot be stopped.", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        self.activityIndicatorView.startAnimating()
                        self.activityIndicatorView.hidden = false
                        self.view.userInteractionEnabled = false
                    }
                }
                else {
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                
                // couldn't load JSON, look at error
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
                
            }
            
            
        })
            
        }
    }
    
    
    @IBAction func retransmitButtonClicked(sender: AnyObject) {
        
        println("retransmit button clicked")
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        
        var alertController = UIAlertController(title: "", message: "Select Duration", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.durations.count {
            var okAction = UIAlertAction(title: "\(self.durations[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                
                self.selectedDuration = self.durations[i]
                self.selectedDurationId = self.durationIds[i]
                self.reTransmitWithDuration(sender.tag)
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func reTransmitWithDuration(id: Int) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        var transmissionData: NSDictionary = youData[id] as NSDictionary
        var transmissionId: Int = transmissionData["id"] as Int
        var archived: String = transmissionData["archived"] as String
        
        var url = "http://\(GlobalVariable.apiUrl)/api/transmissions/retransmit.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&preset_duration_id=\(self.selectedDurationId)&archived=\(archived)"
        println("=======retransmit url========\(url)")
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("notification") != nil {
                    var message :NSString? = jsonResult?.valueForKey("notification") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Transmission retransmitted.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.currentPage = 0
                                self.api!.fetchTransmissions("own", currentPage: self.currentPage)
                            }
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("error") != nil {
                    
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Transmission cannot be retransmitted.", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
                else {
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Something went wrong", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            //                            self.api!.fetchMessages("")
                            self.activityIndicatorView.startAnimating()
                            self.activityIndicatorView.hidden = false
                            self.view.userInteractionEnabled = false
                            
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                
                // couldn't load JSON, look at error
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
                
            }
            
            
        })
            
        }
    }
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        var transmissionData: NSDictionary = youData[sender.tag] as NSDictionary
        var transmissionId: Int = transmissionData["id"] as Int
        var archived: String = transmissionData["archived"] as String
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/delete_transmission.json?api_key=\(apiKey)&transmission_id=\(transmissionId)&archived=\(archived)"
        
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        //        request.HTTPMethod = "POST"
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                //                var transmissionId :NSString? = jsonResult?.valueForKey("transmission_id") as? NSString
                if jsonResult?.valueForKey("transmission") != nil {
                    var message :NSString? = jsonResult?.valueForKey("transmission") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Your transmission has been deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            
                            if Reachability.isConnectedToNetwork() == true {
                                println("Internet connection OK")
                                self.activityIndicatorView.startAnimating()
                                self.activityIndicatorView.hidden = false
                                self.view.userInteractionEnabled = false
                            
                                self.currentPage = 0
                                self.api!.fetchTransmissions("own", currentPage: self.currentPage)
                            }
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else {
                    
                    var errorMessage: NSDictionary = (jsonResult["error"] as NSDictionary)
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "Transmission cannot be deleted.", preferredStyle: UIAlertControllerStyle.Alert)
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            self.activityIndicatorView.stopAnimating()
                            self.activityIndicatorView.hidden = true
                            self.view.userInteractionEnabled = true
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                
                // couldn't load JSON, look at error
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }

        })
            
        }
    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
        // Youmitter code
        
        if results.objectForKey("transmissions") != nil {
            var resultsArr: NSMutableArray = results["transmissions"] as NSMutableArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                
                if self.currentPage == 0 {
                    self.youData = resultsArr
                    self.youTableView!.reloadData()
                }
                else if self.currentPage == 1 {
                    self.youData = resultsArr
                    self.youTableView!.reloadData()
                }
                else {
                    //                    self.universeData.append(resultsArr)
                    self.youData.addObjectsFromArray(resultsArr.subarrayWithRange(NSMakeRange(0, resultsArr.count)))
                    self.youTableView!.reloadData()
                }
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            })
        }
        else if results.objectForKey("error") != nil {
            
            if youData.count == 0 {
                var error: NSString = results["error"] as NSString
                let alertController = UIAlertController(title: "", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
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
                dispatch_async(dispatch_get_main_queue(), {
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                })
            }
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            })
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            var detailsViewController: TransmissionDetailsViewController = segue.destinationViewController as TransmissionDetailsViewController
            var transmissionIndex = self.youTableView.indexPathForSelectedRow()!
            
            detailsViewController.transmissionDetails = self.youData.objectAtIndex(transmissionIndex.row) as NSDictionary
            detailsViewController.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier!.rangeOfString("newTransmission") != nil {
            
            var newTransmissionViewController: NewTransmissionViewController = segue.destinationViewController as NewTransmissionViewController
            newTransmissionViewController.hidesBottomBarWhenPushed = true
        }
        else if segue.identifier == "editTransmission" {
            
            var newTransmissionViewController: NewTransmissionViewController = segue.destinationViewController as NewTransmissionViewController
            newTransmissionViewController.hidesBottomBarWhenPushed = true
            
            var transmissionData: NSDictionary = youData[sender!.tag] as NSDictionary
            
            newTransmissionViewController.editFlag = 1
            newTransmissionViewController.transmissionDetails = transmissionData
            
        }
    }

    @IBAction func searchMenuClicked(sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
    
        alertNotification.setMessageCountAsRead()
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
    
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
