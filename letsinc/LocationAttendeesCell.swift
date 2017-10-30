//
//  LocationAttendeesCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class LocationAttendeesCell: UITableViewCell {

    @IBOutlet weak var userImage1: LSImageView!
    @IBOutlet weak var userImage2: LSImageView!
    @IBOutlet weak var userImage3: LSImageView!
    @IBOutlet weak var numUsersContainer: UIView!
    @IBOutlet weak var numUsersLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var owner: UITableView?
    var indexPath:IndexPath?
    
    var imageTriggered:((UITableViewCell)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
        self.userImage1.activityIndicator.activityIndicatorViewStyle = .gray
        self.userImage1.activityIndicator.activityIndicatorViewStyle = .gray
        self.userImage1.activityIndicator.activityIndicatorViewStyle = .gray
        
        
        self.userImage1.layer.cornerRadius = self.userImage1.frame.size.height / 4
        self.userImage2.layer.cornerRadius = self.userImage2.frame.size.height / 4
        self.userImage3.layer.cornerRadius = self.userImage3.frame.size.height / 4
        self.numUsersContainer.layer.cornerRadius = self.numUsersContainer.frame.size.height / 4
        
        self.userImage3.isHidden = true
    }
    
    func setData(locationAttendees:LocationAttendees)  {
        
        self.cityNameLabel.text = locationAttendees.location.cityName
        self.countryNameLabel.text = locationAttendees.location.countryName
        
        self.userImage1.image = nil
        self.userImage2.image = nil
        self.userImage3.image = nil
        
        let eventUsers:[User] = locationAttendees.attendees
        
        
        self.userNameLabel.isHidden = true
        
        if eventUsers.count > 3 {
            self.userImage1.loadImage(url: eventUsers[0].imageURL)
            self.userImage2.loadImage(url: eventUsers[1].imageURL)
            self.numUsersLabel.text = "+\(eventUsers.count-2)"
            self.numUsersContainer.isHidden = false
            self.userImage1.isHidden = false
            self.userImage2.isHidden = false
            self.userImage3.isHidden = true
        }
        else if eventUsers.count == 3 {
            self.userImage1.loadImage(url: eventUsers[0].imageURL)
            self.userImage2.loadImage(url: eventUsers[1].imageURL)
            self.userImage3.loadImage(url: eventUsers[2].imageURL)

            self.numUsersContainer.isHidden = true
            self.userImage1.isHidden = false
            self.userImage2.isHidden = false
            self.userImage3.isHidden = false
        }
        else if eventUsers.count == 2 {
            self.userImage1.loadImage(url: eventUsers[0].imageURL)
            self.userImage2.loadImage(url: eventUsers[1].imageURL)
            self.userImage3.image = nil
            
            self.numUsersContainer.isHidden = true
            self.userImage1.isHidden = false
            self.userImage2.isHidden = false
            self.userImage3.isHidden = true
        }
        else if eventUsers.count == 1 {
            self.userImage1.loadImage(url: eventUsers[0].imageURL)
            self.userImage2.image = nil
            self.userImage3.image = nil
            
            self.numUsersContainer.isHidden = true
            self.userImage1.isHidden = false
            self.userImage2.isHidden = true
            self.userImage3.isHidden = true
            self.userNameLabel.text = eventUsers[0].username
            self.userNameLabel.isHidden = false
        }
        
        
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
