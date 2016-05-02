//
//  NotificationCount.swift
//  NewUIYoumitter
//
//  Created by HOME on 21/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//



class NotificationCount {
    
    var currentSpeed = 0.0
    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var alertCount: Int = 0
    var messageCount: Int = 0
    
    var unreadAlertCount: Int {
        if let alertCountIsNotNill = defaults.objectForKey("unreadAlertCount") as? Int {
            self.alertCount = defaults.objectForKey("unreadAlertCount") as Int
        }
        return self.alertCount
        
    }
    var unreadMessageCount: Int {
        if let messageCountIsNotNill = defaults.objectForKey("unreadMessageCount") as? Int {
            self.messageCount = defaults.objectForKey("unreadMessageCount") as Int
        }
        return self.messageCount
        
    }
    
    func checkForAlertCount() -> Bool {
//        if let alertCountIsNotNill = defaults.objectForKey("unreadAlertCount") as? Int {
//            self.alertCount = defaults.objectForKey("unreadAlertCount") as Int
//        }
        if self.unreadAlertCount == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func checkForMessageCount() -> Bool {
//        if let messageCountIsNotNill = defaults.objectForKey("unreadMessageCount") as? Int {
//            self.messageCount = defaults.objectForKey("unreadMessageCount") as Int
//        }
        if self.unreadMessageCount == 0 {
            return true
        }
        else {
            return false
        }
    }
    
    func setAlertCountAsRead() {
        
        defaults.setObject(0, forKey: "unreadAlertCount")
        
        
    }
    
    func setMessageCountAsRead() {
        
        defaults.setObject(0, forKey: "unreadMessageCount")
       
        
    }
    
    
    
}