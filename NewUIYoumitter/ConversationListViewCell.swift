//
//  ConversationListViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 27/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ConversationListViewCell: UITableViewCell {

    @IBOutlet var senderImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var moreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
