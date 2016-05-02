//
//  UserIntersetSelectionViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 27/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

protocol UserIntersetSelectionViewControllerDelegate
{
    func UserIntersetSelectionViewResponse(interests: NSMutableArray)
}

class UserIntersetSelectionViewController: UIViewController, APIControllerProtocol {

    @IBOutlet var userInterestTableView: UITableView!
    
    var userInterestNames : NSMutableArray = NSMutableArray()
    var userInterestIds : NSMutableArray = NSMutableArray()
//    var listOfSelectedIds: NSMutableArray = NSMutableArray()
    var api:APIController?
    var interestNames: NSMutableArray = NSMutableArray()
    var interestIds: NSMutableArray = NSMutableArray()
    var apiKey: String = ""
    var lastSelectedRow: NSIndexPath? = nil
    
    var delegate: UserIntersetSelectionViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        api = APIController(delegate: self)
        api!.loadUserDefaultsData()
        apiKey = api!.apiKey
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            api!.fetchUserInterests()
        }
        
        println("\(self.userInterestNames)")
        println("\(self.userInterestIds)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func tableView(tableView:UITableView!, numberOfRowsInSection section:Int) -> Int
    {
        return interestNames.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("userInterestsCell") as UITableViewCell
        var name: String = interestNames[indexPath.row] as String
        cell.textLabel.text = interestNames[indexPath.row] as? String
        
//        for interestName in userInterestNames {
        
//            if name == interestName as String {
            var array = userInterestNames as Array
//            array = userInterestNames
                if array.contains(name) {
                    cell.selected = true
                }
//            }
            else {
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
        
        var name: String = interestNames[indexPath.row] as String
        var array = userInterestNames as Array
//        var arrayIds = interestIds as Array
        if array.contains(name) {
            userInterestNames.removeObject(name)
            var id = interestIds[indexPath.row] as Int
            userInterestIds.removeObject(id)
        }
        else {
            userInterestNames.addObject(name)
            var id = interestIds[indexPath.row] as Int
            userInterestIds.addObject(id)
        }
        
        println("self.userInterestNames = \(self.userInterestNames)")
        println("self.userInterestIds = \(self.userInterestIds)")
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
    

    
    func didReceiveAPIResults(results: NSDictionary) {
        
//        if results != nil {
            var interests: NSArray = results["interests"] as NSArray
            // Youmitter code
            //        var resultsArr: NSArray = results["results"] as NSArray
            dispatch_async(dispatch_get_main_queue(), {
                for interest in interests {
                    var eachInterest: NSDictionary = interest as NSDictionary
                    //                        println("eachConstellation = \(eachConstellation)")
                    var interestName: String = eachInterest["name"] as String
                    var interestId: Int = eachInterest["id"] as Int
                    self.interestNames.addObject(interestName)
                    self.interestIds.addObject(interestId)
                }
                
                self.userInterestTableView!.reloadData()
                
            })
//        }
        
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        
//        self.delegate?.UserIntersetSelectionViewResponse(listOfSelectedIds)
        navigationController?.popViewControllerAnimated(true)
    }
    

}

extension Array {
    func contains<T where T : Equatable>(obj: T) -> Bool {
        return self.filter({$0 as? T == obj}).count > 0
    }
}