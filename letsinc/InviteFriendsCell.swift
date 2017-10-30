//
//  InviteFriendsCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class InviteFriendsCell: UITableViewCell {

    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.inviteButton.layer.borderWidth = 0.5
        self.inviteButton.layer.cornerRadius = self.inviteButton.frame.size.height / 2
        self.inviteButton.layer.borderColor = UIColor(rgb: 0xA0AFB4).cgColor
        
        let attributedStringNormal = NSMutableAttributedString(string: "INVITE")
        attributedStringNormal.addAttribute(NSKernAttributeName, value: CGFloat(1.0), range: NSRange(location: 0, length: attributedStringNormal.length))
        attributedStringNormal.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgb:0xA0AFB4) , range: NSRange(location: 0, length: attributedStringNormal.length))
        
        let attributedStringSelected = NSMutableAttributedString(string: "INVITED")
        attributedStringSelected.addAttribute(NSKernAttributeName, value: CGFloat(1.0), range: NSRange(location: 0, length: attributedStringSelected.length))
        attributedStringSelected.addAttribute(NSForegroundColorAttributeName, value: UIColor(rgb:0x40C4EA) , range: NSRange(location: 0, length: attributedStringSelected.length))

        
        self.inviteButton.setAttributedTitle(attributedStringNormal, for: .normal)
        self.inviteButton.setAttributedTitle(attributedStringSelected, for: .selected)
        
        self.inviteButton.titleEdgeInsets = UIEdgeInsetsMake(5.0, 0.0, 0.0, 0.0)
        
        
    }
    
    @IBAction func onInviteButtonTriggered(_ sender: UIButton) {
        
        
        if sender.isSelected {
            // set deselected
            self.buttonWidthConstraint.constant = 70
            sender.layoutIfNeeded()
            sender.isSelected = false
            sender.layer.borderWidth = 0.5
            sender.layer.cornerRadius = sender.frame.size.height / 2
            sender.layer.borderColor = UIColor(rgb: 0xA0AFB4).cgColor
            
        
        } else {
            // set selected
            self.buttonWidthConstraint.constant = 90
            sender.layoutIfNeeded()
            sender.isSelected = true
            sender.layer.borderWidth = 0.5
            sender.layer.cornerRadius = sender.frame.size.height / 2
            sender.layer.borderColor = UIColor(rgb: 0x40C4EA).cgColor
            
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}
