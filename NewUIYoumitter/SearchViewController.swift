//
//  SearchViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 26/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var searchDataText: UITextField!
    @IBOutlet var searchLocationText: UITextField!
    @IBOutlet var searchCategoryText: UITextField!
    
    @IBOutlet var clickeMeButton: UIButton!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    
    var selectedCategoryId: String = ""
    var categoryIds = ["4", "8", "7", "2", "5", "3", "6", "1"]
    var categories = ["Claims(& Manifestations)", "Confessions(& Secrets)", "Help(& Advice)", "Love(& Romance)", "Memorials(& Prayers)", "Thanks (& Gratitude)", "Thoughts (& Rhetoric)", "Wishes (& Desires)"]
    var alertNotification = NotificationCount()
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
        
        //Looks for single or multiple taps.
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
        
        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        else {
            println("no swrevealcontroller")
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.sideMenuController()?.sideMenu?.delegate = self
    }

    //Calls this function when the tap is recognized.
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sideMenuClicked(sender: AnyObject) {
        
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

    @IBAction func homeButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
        
    }

    
    
    @IBAction func clickMeClicked(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "Select Category", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.categories.count {
            var okAction = UIAlertAction(title: "\(self.categories[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                
                println(self.categories[i])
                self.selectedCategoryId = self.categoryIds[i]
                self.clickeMeButton.setTitle(self.categories[i], forState: UIControlState.Normal)
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchToUniverse" {
            println("====== segue \(segue.identifier) ====== ")
            //            println("======  ====== ")
            var toUniverseController: UniverseController = segue.destinationViewController as UniverseController
            toUniverseController.searchFlag = 1
            toUniverseController.searchData = searchDataText.text
            toUniverseController.searchLocation = searchLocationText.text
            toUniverseController.searchCategory = selectedCategoryId
            
            //            searchController.hidesBottomBarWhenPushed = true
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
        
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
        destViewController.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(destViewController, animated: true)
        
    }

}
