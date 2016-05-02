//
//  SeeActivityTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 05/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SeeActivityTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameText: UILabel!
    @IBOutlet var timeText: UILabel!
    @IBOutlet var bodyContentText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
