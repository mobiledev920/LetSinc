//
//  SearchFriendCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 12/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class SearchFriendCell: UITableViewCell {

    static let DELETE_ACTION:String = "delete"
    static let REJECT_ACTION:String = "reject"
    static let ACCEPT_ACTION:String = "accept"
    static let CANCEL_ACTION:String = "cancel"
    
    @IBOutlet weak var userImageView: LSImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLocationLabelContainer: UIView!
    @IBOutlet weak var action2Button: UIButton!
    @IBOutlet weak var action1Button: UIButton!
    // red EC644B
    // green 3FC380
    let red = UIColor(rgb: 0xEC644B)
    let green = UIColor(rgb: 0x40c4ea)
    
    var actionTriggered:((String, UITableViewCell)->())?
    var imageTriggered:((UITableViewCell)->())?
    
    var button1Action:String?
    var button2Action:String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        self.action2Button.layer.borderWidth = 0.0
        self.action2Button.layer.cornerRadius = self.action2Button.frame.size.height / 2
        self.action2Button.backgroundColor = UIColor(rgb: 0xA0AFB4)
        
        self.action1Button.layer.borderWidth = 0.0
        self.action1Button.layer.cornerRadius = self.action1Button.frame.size.height / 2
        self.action1Button.backgroundColor = UIColor(rgb: 0xA0AFB4)
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 4
        self.userLocationLabelContainer.layer.cornerRadius = self.userLocationLabelContainer.frame.size.height / 2
    }
    
    @IBAction func onAction2ButtonTriggered(_ sender: UIButton) {
        self.actionTriggered?(self.button2Action!, self)
    }
    
    @IBAction func onAction1ButtonTriggered(_ sender: UIButton) {
        self.actionTriggered?(self.button1Action!, self)
    }
    @IBAction func onUserImageTriggered(_ sender: UIButton) {
        self.imageTriggered?(self)
        
    }

    func setIsFriendsSection() {
        self.action2Button.isHidden = false
        self.action1Button.isHidden = true
        self.action2Button.layer.borderWidth = 1.5
        self.action2Button.layer.borderColor = UIColor.white.cgColor
        self.action2Button.setTitle("Delete", for: .normal)
        self.action2Button.setTitleColor(UIColor.white, for: .normal)
        self.action2Button.backgroundColor = UIColor.clear
        self.button1Action = nil
        self.button2Action = SearchFriendCell.DELETE_ACTION
    }
    
    func setIsFriendshipRequestsSection() {
        self.action2Button.isHidden = false
        self.action1Button.isHidden = false
        self.action2Button.layer.borderWidth = 0.0
        self.action1Button.layer.borderWidth = 0.0
        self.action1Button.setTitle("Confirm", for: .normal)
        self.action2Button.setTitle("Cancel", for: .normal)
        self.action1Button.setTitleColor(UIColor.white, for: .normal)
        self.action1Button.backgroundColor = green
        self.action2Button.setTitleColor(UIColor.white, for: .normal)
        self.action2Button.backgroundColor = red
        self.button1Action = SearchFriendCell.ACCEPT_ACTION
        self.button2Action = SearchFriendCell.REJECT_ACTION
        
    }
    
    func setIsPendingFriendshipsSection() {
        self.action2Button.isHidden = false
        self.action1Button.isHidden = true
        self.action2Button.layer.borderWidth = 1.5
        self.action2Button.layer.borderColor = UIColor.white.cgColor
        self.action2Button.setTitle("Cancel", for: .normal)
        self.action2Button.setTitleColor(UIColor.white, for: .normal)
        self.action2Button.backgroundColor = UIColor.clear
        self.button1Action = nil
        self.button2Action = SearchFriendCell.CANCEL_ACTION
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
