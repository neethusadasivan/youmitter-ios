//
//  SelectConstellationViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 02/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SelectConstellationViewController: UIViewController, APIControllerProtocol {

    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var apiKey: String = ""
    var api:APIController?
    var constellations = NSMutableArray()
    var constellationIds = NSMutableArray()
    var wholeConstellations = NSMutableArray()
    var wholeConstellationIds = NSMutableArray()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        println("====constellations======\(constellations)")
        println("====constellationIds======\(constellationIds)")
        println("====wholeConstellations======\(wholeConstellations)")
        println("====wholeConstellationIds======\(wholeConstellationIds)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return self.wholeConstellations.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("constellationCell") as UITableViewCell
        var name: String = self.wholeConstellations[indexPath.row] as String
        cell.textLabel.text = self.wholeConstellations[indexPath.row] as? String
        
        //        for interestName in userInterestNames {
        
        //            if name == interestName as String {
        var array = self.constellations as Array
        //            array = userInterestNames
        if array.contains(name) {
            constellationIds.addObject(self.wholeConstellationIds[indexPath.row] as Int)
            cell.selected = true
        }
            //            }
        else {
            constellationIds.removeObject(self.wholeConstellationIds[indexPath.row] as Int)
            cell.selected = false
        }
        //        }
        if cell.selected == true {
            cell.accessoryType = .Checkmark
        }
        else {
            cell.accessoryType = .None
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //        if let last = lastSelectedRow {
        //            let oldSelectedCell = tableView.cellForRowAtIndexPath(last)
        //            oldSelectedCell?.accessoryType = .None
        //
        //
        //        }
        //        lastSelectedRow = indexPath
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (cell?.accessoryType == UITableViewCellAccessoryType.None) {
            
            cell?.accessoryType = .Checkmark
            cell?.selected = true
            
        }
        else if (cell?.accessoryType == UITableViewCellAccessoryType.Checkmark) {
            cell?.accessoryType = .None
            cell?.selected = false
        }
        
        var name: String = wholeConstellations[indexPath.row] as String
        println("selected name = \(name)")
        var array = constellations as Array
        //        var arrayIds = interestIds as Array
        
        if wholeConstellations[0] as String == "No constellation found" {
            
        }
        else {
            if array.contains(name) {
                println("contains name")
                constellations.removeObject(name)
                var id = wholeConstellationIds[indexPath.row] as Int
                constellationIds.removeObject(id)
            }
            else {
                println("doesnt contain name")
                constellations.addObject(name)
                var id = wholeConstellationIds[indexPath.row] as Int
                constellationIds.addObject(id)
            }
        }
        println("constellations = \(self.constellations)")
        println("constellationIds = \(self.constellationIds)")
        //        var interestArray  = interestNames as NSArray
        ////        var arrayValues = userInterestNames as Array
        //        var listOfSelectedIds = userInterestIds as Array
        ////        userInterestIds = []
        //        for i in userInterestNames {
        ////            if interestArray.contains(i) {
        //            var listOfSelectedIds = userInterestIds as Array
        //
        //                var index = interestArray.indexOfObject(i)
        //                var id = interestIds[index] as Int
        //            if listOfSelectedIds.contains(id) {
        //
        //            }
        //            else {
        //                userInterestIds.addObject(id)
        //            }
        ////            }
        //        }
        ////        userInterestIds = []
        ////        userInterestIds = listOfSelectedIds
        
        
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func didReceiveAPIResults(results: NSDictionary) {
    }
}
