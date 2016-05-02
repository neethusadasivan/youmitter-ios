//
//  MenuController.swift
//  NewUIYoumitter
//
//  Created by HOME on 10/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {

    @IBOutlet var menuTableView: UITableView!
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
    var threeConstellations: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let userConstellationsIsNotNill = defaults.objectForKey("userConstellations") as? NSMutableArray {
            self.userConstellations = defaults.objectForKey("userConstellations") as NSMutableArray
        }
        else {
            self.userConstellations = ["No constellations"]
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
        
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        //        tableView.backgroundColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor.darkGrayColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
//        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.sections.count
    }
    
  
    
    @IBAction func logOutButtonClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.logOutButtonClicked()
        
    }
    
}
