//
//  AlertsCustomTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 27/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class AlertsCustomTableViewCell: UITableViewCell {

    @IBOutlet var alertImageView: UIImageView!
    @IBOutlet var alertTypeLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var remindLaterButton: UIButton!
    @IBOutlet var deleteAlertButton: UIButton!
    @IBOutlet var alertView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
