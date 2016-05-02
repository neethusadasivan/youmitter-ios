//
//  ConstellationController.swift
//  NewUIYoumitter
//
//  Created by HOME on 20/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ConstellationController: UIViewController, APIControllerProtocol, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var constellationTableView: UITableView!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    
    var imageCache = [String : UIImage]()
    let kCellIdentifier: String = "ConstellationCell"
    var apiKey: String = ""
    var currentPage: Int = 1
    var constellationData: NSMutableArray = []
    var api: APIController?
    var urlString: NSDictionary?
    var categoryImageSTring: String = ""
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var refreshControl:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        self.constellationTableView.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
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
        
        self.sideMenuController()?.sideMenu?.delegate = self;
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
            activityIndicatorView.startAnimating()
            self.view.userInteractionEnabled = false
            api!.fetchTransmissions("constellation", currentPage: 1)
            
        }
        api!.delegate = self
        apiKey = api!.apiKey
        println("----------ConstellationController----------")
        
    }

    func refresh(sender:AnyObject)
    {
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.constellationTableView!.reloadData()
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return constellationData.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        println("displaying row = \(indexPath.row)")
        println("constellationData count = \(constellationData.count)")
        var row = indexPath.row
        //        prinltn("displaying content = \(universeData)")
        if row == constellationData.count-1 {
            self.currentPage += 1
            println("Reaches end")
            
            if Reachability.isConnectedToNetwork() == true {
                println("Internet connection OK")
                api!.fetchTransmissions("universe",currentPage: currentPage)
                self.activityIndicatorView.startAnimating()
                self.activityIndicatorView.hidden = false
                self.view.userInteractionEnabled = false
            
                self.refreshControl = UIRefreshControl()
                self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
                self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
                self.constellationTableView.addSubview(refreshControl)
            }
            
        }
        else {
            println("row = \(row)")
            
        }
    }

    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let cell: ConstellationTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as ConstellationTableViewCell
        if urlString == nil {
            return 133.00;
        }
        else {
            return 220.00
        }
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: ConstellationTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as ConstellationTableViewCell
        
        cell.backgroundColor = UIColor(red: (204/255.0), green: (204/255.0), blue: (204/255.0), alpha:1.0)
        
        let rowData: NSDictionary = self.constellationData[indexPath.row] as NSDictionary
        cell.affirmButton.tag = rowData["id"] as Int
        cell.commentButton.tag = rowData["id"] as Int
        
        
        var tapGestureRecognizer = UITapGestureRecognizer(target:self, action:Selector("affirmButtonClicked:"))
        cell.affirmImageView.tag = rowData["id"] as Int
        cell.affirmImageView.addGestureRecognizer(tapGestureRecognizer)
        cell.affirmImageView.userInteractionEnabled = true
        
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
        //        let categoryId: Int = rowData["category_id"] as Int
        
        var commentCount = rowData["comment_count"] as? Int
        if commentCount != 0 {
            cell.commentButton.setTitle(" Comment(\(commentCount!))", forState: UIControlState.Normal)
        }
        else {
            cell.commentButton.setTitle(" Comment(0)", forState: UIControlState.Normal)
        }
        
        cell.transmissionImageView.contentMode = UIViewContentMode.ScaleAspectFill
        cell.transmissionImageView.clipsToBounds = true
        
        urlString = (rowData["photo"]?["photo"] as? NSDictionary)
        
        
        if (urlString != nil) {
            cell.transmissionImageView.hidden = false
            cell.heightForTransmissionImage.constant = 79.0
            
            let urlForImage:NSString = urlString?.valueForKey("url") as NSString
            var transImage = self.imageCache[urlForImage]
            
            
            //                  Download an NSData representation of the image at the URL
            //            let imgData = NSData(contentsOfURL: imgURL!)
            //                    cell.imageView.image = UIImage(data: imgData!)
            //            cell.transmissionImage.image = UIImage(data: imgData!)
            
            if (transImage == nil) {
                //                var categoryImageUrl: NSURL? = NSURL(string: categoryImageString)
                var transImgURL: NSURL = NSURL(string: urlForImage)!
                
                // Download an NSData representation of the image at the URL
                let request: NSURLRequest = NSURLRequest(URL: transImgURL)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                    if error == nil {
                        transImage = UIImage(data: data)
                        
                        // Store the image in to our cache
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
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    //                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                    //                    cellToUpdate.categoryImageView?.image = image
                    //                }
                    cell.transmissionImageView.image = transImage
                })
            }
        }
        else {
            cell.transmissionImageView.hidden = true
            cell.heightForTransmissionImage.constant = 0.0
            //            cell.transmissionImage.image = UIImage(named: "tempimage.png")
        }
        
        let categoryId: Int = rowData["category_id"] as Int
        // Category image fetching end
        let categoryImageString = "https://ymt.s3.amazonaws.com/categories/holo_light/xhdpi/categories_\(categoryId).png"
        var image = self.imageCache[categoryImageString]
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
                cell.categoryImageView.image = image
            })
        }
        println("======== tableview 22 ==========")
        return cell
    }

    func didReceiveAPIResults(results: NSDictionary) {
        // Youmitter code
        if results.objectForKey("transmissions") != nil {
            var resultsArr: NSMutableArray = results["transmissions"] as NSMutableArray
            
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                if self.currentPage == 1 {
                    self.constellationData = resultsArr
                    self.constellationTableView!.reloadData()
                }
                else {
                    //                    self.universeData.append(resultsArr)
                    self.constellationData.addObjectsFromArray(resultsArr.subarrayWithRange(NSMakeRange(0, resultsArr.count)))
                    self.constellationTableView!.reloadData()
                }
                
            })
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.hidden = true
            self.view.userInteractionEnabled = true
            
        }
        else {
            println("===== not found =====")
            if constellationData.count == 0 {
                let alertController = UIAlertController(title: "", message: "No constellations found.", preferredStyle: UIAlertControllerStyle.Alert)
                var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    println("Ok Pressed")
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.hidden = true
                    self.view.userInteractionEnabled = true
                }
                alertController.addAction(okAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            //            self.view.makeToast(message: "No constellations found")
            }
            else {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.hidden = true
                self.view.userInteractionEnabled = true
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            
            var detailsViewController: TransmissionDetailsViewController = segue.destinationViewController as TransmissionDetailsViewController
            var transmissionIndex = self.constellationTableView.indexPathForSelectedRow()!
            
            detailsViewController.transmissionDetails = self.constellationData.objectAtIndex(transmissionIndex.row) as NSDictionary
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
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/transmissions/affirm.json?api_key=\(apiKey)&transmission_id=\(transmissionId)"
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
                if jsonResult?.valueForKey("message") != nil {
                    var message :NSString? = jsonResult?.valueForKey("message") as? NSString
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Your transmission has been affirmed, Thank You.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
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
                    var errorMessage :NSString? = jsonResult?.valueForKey("affirm") as? NSString
                    if (errorMessage == nil) {
                        errorMessage = "Transmission cannot be affirmed."
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(errorMessage!)", preferredStyle: UIAlertControllerStyle.Alert)
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
    
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }
    
    @IBAction func sideMenuClicked(sender: AnyObject) {
        
        println("side menu clicked")
        toggleSideMenuView()
        
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
        
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

    
}
