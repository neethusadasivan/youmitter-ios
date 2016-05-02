//
//  CommentsTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 02/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class CommentsTableViewCell: UITableViewCell {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var fromUserLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var abusiveButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
