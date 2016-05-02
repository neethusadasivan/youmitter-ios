//
//  Qbutton.swift
//  NewUIYoumitter
//
//  Created by HOME on 04/02/16.
//  Copyright (c) 2016 Ruby Software. All rights reserved.
//

import Foundation
import UIKit

class Qbutton: UIButton {
    
    // Images
    let selectedImage = UIImage(named: "Selected")
    let unselectedImage = UIImage(named: "Unselected")
    
    
    //Bool Property
    override var selected: Bool{
        didSet{
            if selected {
                self.setImage(selectedImage, forState: UIControlState.Normal)
            }else{
                self.setImage(unselectedImage, forState: UIControlState.Normal)
            }
            NSUserDefaults.standardUserDefaults().setObject(selected, forKey: "isBtnChecked")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    override init(frame: CGRect){
        super.init(frame:frame)
        self.layer.masksToBounds = true
        self.setImage(unselectedImage, forState: UIControlState.Normal)
        
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buttonClicked(sender: UIButton) {
        self.selected = !self.selected
    }
}