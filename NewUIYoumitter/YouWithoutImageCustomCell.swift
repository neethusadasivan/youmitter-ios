//
//  YouWithoutImageCustomCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 24/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class YouWithoutImageCustomCell: UITableViewCell {

    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var stopTitleButton: UIButton!
    @IBOutlet var retransmitTitleButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var overFlowButton: UIButton!
    @IBOutlet var widthForOverFlowButton: NSLayoutConstraint!
    
    @IBOutlet var editButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
