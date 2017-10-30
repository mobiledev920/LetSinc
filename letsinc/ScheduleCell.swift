//
//  ScheduleCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

protocol ScheduleCellDelegate {
    func showLikedUsers(_ event: Event)
}

class ScheduleCell: UITableViewCell {

    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var locationImageView: LSImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var numLikeButton: UIButton!
    
    var schedule: Event!
    var delegate: ScheduleCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.size.height / 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func likeButtonTriggered(_ sender: UIButton) {
        if self.schedule.userID == currentUser?.uid {
            return
        }
        
        let filteredLikes = schedule.likes.filter { (like) -> Bool in
            return like.byUserID == currentUser?.uid
        }
        
        if filteredLikes.count > 0 {
            let index = schedule.likes.index(where: { (like) -> Bool in
                return like.uid == filteredLikes.first?.uid
            })
            schedule.likes.remove(at: index!)
            sender.setImage(#imageLiteral(resourceName: "icon_unlike"), for: .normal)
        } else {
            let like = Like(uid: UUID().uuidString, byUserID: (currentUser?.uid)!, toSchedule: self.schedule.uid, status: true)
            schedule.likes.append(like)
            sender.setImage(#imageLiteral(resourceName: "icon_like"), for: .normal)
        }
        
        FirebaseAPI.sharedInstance.editEvent(eventID: self.schedule.uid, location: self.schedule.location, startDate: self.schedule.startDate, endDate: self.schedule.endDate, likes: self.schedule.likes, byUser: self.schedule.userID)
        
        self.numLikeButton.setTitle(String(self.schedule.likes.count), for: .normal)
    }
    
    @IBAction func numberOfLikeButtonTriggered(_ sender: Any) {
        if let delegate = delegate, self.schedule.likes.count > 0 {
            delegate.showLikedUsers(self.schedule)
        }
    }
}
