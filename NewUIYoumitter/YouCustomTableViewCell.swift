//
//  YouCustomTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 21/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class YouCustomTableViewCell: UITableViewCell {

    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var transmissionImageView: UIImageView!
    @IBOutlet var heightConstraintForTransmissionImage: NSLayoutConstraint!
    @IBOutlet var widthForOverFlowButton: NSLayoutConstraint!
    @IBOutlet var stopTitleButton: UIButton!
    @IBOutlet var retransmitTitleButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var overFlowButton: UIButton!

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
