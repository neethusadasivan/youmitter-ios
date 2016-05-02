//
//  UniverseCustomCell.swift
//  NewUIYoumitter
//
//  Created by HOME on 21/05/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class UniverseCustomCell: UITableViewCell {

    @IBOutlet var categoryImageView: UIImageView!
    @IBOutlet var fromLabel: UILabel!
    @IBOutlet var toLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var transmissionImage: UIImageView!
    @IBOutlet var heightConstraintForTransmissionImage: NSLayoutConstraint!
    @IBOutlet var affirmButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var affirmImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
