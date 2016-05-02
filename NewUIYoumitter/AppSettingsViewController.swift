//
//  AppSettingsViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 04/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController, ENSideMenuDelegate {

    @IBOutlet var sideMenuButton: UIBarButtonItem!
    @IBOutlet var fetchFrequencySwitch: UISwitch!
    @IBOutlet var recentTransmissionSwitch: UISwitch!
    @IBOutlet var shareOnSocialMediaSwitch: UISwitch!
    @IBOutlet var unreadMessageLabel: UILabel!
    @IBOutlet var unreadAlertLabel: UILabel!
    @IBOutlet var fetchFrequencyButton: UIButton!
    
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var transType: String = "", shareMedia: String = "", fetchFrequency: String = ""
    var alertNotification = NotificationCount()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.unreadAlertLabel.text = " \(alertNotification.unreadAlertCount) "
        self.unreadMessageLabel.text = " \(alertNotification.unreadMessageCount) "
        self.unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
        self.unreadMessageLabel.hidden = alertNotification.checkForMessageCount()

        if self.revealViewController() != nil {
            sideMenuButton.target = self.revealViewController()
            sideMenuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        
        self.sideMenuController()?.sideMenu?.delegate = self
        
        if let transTypeIsNotNill = defaults.objectForKey("transType") as? String {
            self.transType = defaults.objectForKey("transType") as String
        }
        if self.transType == "recent" {
            recentTransmissionSwitch.setOn(true, animated:true)
        }
        else {
            recentTransmissionSwitch.setOn(false, animated:true)
        }
        
        if let shareMediaIsNotNill = defaults.objectForKey("shareMedia") as? String {
            self.shareMedia = defaults.objectForKey("shareMedia") as String
        }
        if self.shareMedia == "on" {
            shareOnSocialMediaSwitch.setOn(true, animated:true)
        }
        else {
            shareOnSocialMediaSwitch.setOn(false, animated:true)
        }
        if let fetchFrequencyIsNotNill = defaults.objectForKey("fetchFrequency") as? String {
            self.fetchFrequency
                = defaults.objectForKey("fetchFrequency") as String
        }
        if self.fetchFrequency == "" {
            self.fetchFrequencyButton.setTitle("Medium", forState: UIControlState.Normal)
        }
        else {
            self.fetchFrequencyButton.setTitle(self.fetchFrequency, forState: UIControlState.Normal)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func fetchFrequencyClicked(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "Select fetch frequency", preferredStyle: UIAlertControllerStyle.Alert)
        var frequencyArray = ["Slow", "Medium", "Fast"]
        
        for i in 0 ..< frequencyArray.count {
            var okAction = UIAlertAction(title: "\(frequencyArray[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                self.fetchFrequencyButton.setTitle(frequencyArray[i], forState: UIControlState.Normal)
                    self.defaults.setObject("\(frequencyArray[i])", forKey: "fetchFrequency")
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func recentTransmissionChanged(sender: AnyObject) {
        
        if recentTransmissionSwitch.on {
            defaults.setObject("recent", forKey: "transType")
        }
        else {
            defaults.setObject("random", forKey: "transType")
        }
        
    }
    
    @IBAction func shareOnSocialMediaChanged(sender: AnyObject) {
        
        if shareOnSocialMediaSwitch.on {
            defaults.setObject("on", forKey: "shareMedia")
        }
        else {
            defaults.setObject("off", forKey: "shareMedia")
        }
        
    }
    
    
    @IBAction func homeButtonClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.homeButtonClicked()
    }
    
//    @IBAction func sideMenuClicked(sender: AnyObject) {
//        
//    }
    
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
    
    @IBAction func searchMenuClicked(sender: AnyObject) {
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SearchViewController") as UIViewController
//        destViewController.hidesBottomBarWhenPushed = true
//        
//        navigationController?.pushViewController(destViewController, animated: true)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.searchMenuclicked()
    }
    
    @IBAction func messageMenuClicked(sender: AnyObject) {
        
        alertNotification.setMessageCountAsRead()
        unreadMessageLabel.hidden = alertNotification.checkForMessageCount()
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MessagesViewController") as UIViewController
//        destViewController.hidesBottomBarWhenPushed = true
//        
//        navigationController?.pushViewController(destViewController, animated: true)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.messageMenuClicked()
    }
    
    @IBAction func alertMenuClicked(sender: AnyObject) {
        
        alertNotification.setAlertCountAsRead()
        unreadAlertLabel.hidden = alertNotification.checkForAlertCount()
//        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
//        var destViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AlertsViewController") as UIViewController
//        destViewController.hidesBottomBarWhenPushed = true
//        
//        navigationController?.pushViewController(destViewController, animated: true)
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.alertMenuClicked()
    }

}
