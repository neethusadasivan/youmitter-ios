//
//  ViewMembersTableViewCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 06/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class ViewMembersTableViewCell: UITableViewCell {

    @IBOutlet var memberNameLabel: UILabel!
    @IBOutlet var adminIcon: UIImageView!
    @IBOutlet var removeButton: UIButton!
    @IBOutlet var removeImageButton: UIButton!
    @IBOutlet var memberImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
