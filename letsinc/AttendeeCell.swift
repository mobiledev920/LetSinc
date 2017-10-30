//
//  AttendeeCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class AttendeeCell: UITableViewCell {

    @IBOutlet weak var userImageView: LSImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLocationLabelContainer: UIView!
    
    var imageTriggered:((AttendeeCell)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 4
        self.userLocationLabelContainer.layer.cornerRadius = self.userLocationLabelContainer.frame.size.height / 2
    }

    @IBAction func onImageTriggered(_ sender: UIButton) {
        self.imageTriggered?(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
