//
//  ViewRequestTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 06/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ViewRequestTableViewCell: UITableViewCell {

    
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var removeTextButton: UIButton!
    @IBOutlet var removeImageButton: UIButton!
    @IBOutlet var acceptTextButton: UIButton!
    @IBOutlet var acceptImageButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
