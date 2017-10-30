//
//  LikedUserTableViewCell.swift
//  LetSinc
//
//  Created by admin on 10/15/17.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class LikedUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: LSImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var owner: UITableView?
    var indexPath:IndexPath?
    
    var imageTriggered:((UITableViewCell)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 4
    }
    
    func setData(_ likedUser: User)  {
        
        self.cityNameLabel.text = likedUser.currentLocation
        self.userNameLabel.text = likedUser.username
        
        self.userImage.image = nil
        self.userImage.loadImage(url: likedUser.imageURL)
    }

    @IBAction func onUserImageTriggered(_ sender: UIButton) {
        self.imageTriggered?(self)
    }
    
    @IBAction func onSelectButtonTriggered(_ sender: UIButton) {
        self.owner!.selectRow(at: self.indexPath!, animated: false, scrollPosition: .none)
        self.owner!.delegate!.tableView!(self.owner!, didSelectRowAt: self.indexPath!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
