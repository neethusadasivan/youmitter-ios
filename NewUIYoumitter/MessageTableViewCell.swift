//
//  MessageTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 26/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNamelabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var muteButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var messageView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
