//
//  SearchAttendeesLocationCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 28/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class SearchAttendeesLocationCell: UITableViewCell {

    @IBOutlet weak var locationImageView: LSImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var cityCountryNameLabel: UILabel!
    
    @IBOutlet weak var userImage1: LSImageView!
    @IBOutlet weak var userImage2: LSImageView!
    @IBOutlet weak var userImage3: LSImageView!
    @IBOutlet weak var numUsersContainer: UIView!
    @IBOutlet weak var numUsersLabel: UILabel!
    
    let formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.size.height / 4
        self.userImage1.layer.cornerRadius = self.userImage1.frame.size.height / 4
        self.userImage2.layer.cornerRadius = self.userImage2.frame.size.height / 4
        self.userImage3.layer.cornerRadius = self.userImage3.frame.size.height / 4
        self.numUsersContainer.layer.cornerRadius = self.numUsersContainer.frame.size.height / 4
        
        self.userImage3.isHidden = true
    }
    
    func setData(locationAttendees:LocationAttendees, event:Event)  {
        
        let startDay = Calendar.current.component(.day, from: event.startDate)
        let startMonth = Calendar.current.component(.month, from: event.startDate)
        let startMonthName = formatter.monthSymbols[startMonth-1]
        let startYear = Calendar.current.component(.year, from: event.startDate)
        
        let endDay = Calendar.current.component(.day, from: event.endDate)
        let endMonth = Calendar.current.component(.month, from: event.endDate)
        let endMonthName = formatter.monthSymbols[endMonth-1]
        let endYear = Calendar.current.component(.year, from: event.endDate)
        
        var dateText:String = ""
        if startYear != endYear {
            dateText = "\(startMonthName) \(startDay), \(startYear) - \(endMonthName) \(endDay), \(endYear)"
        }
        else {
        
            if startMonth != endMonth {
                dateText = "\(startMonthName) \(startDay) - \(endMonthName) \(endDay), \(endYear)"
            }
            else {
                dateText = "\(startMonthName) \(startDay) - \(endDay), \(endYear)"
            }
            
        }
        
        self.cityNameLabel.text = "\(locationAttendees.location.cityName), \(dateText)"
        self.cityCountryNameLabel.text = locationAttendees.location.countryName
        
        self.userImage1.image = nil
        self.userImage2.image = nil
        self.userImage3.image = nil
        
        let eventUsers:[User] = locationAttendees.attendees
        
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
        }
        
        
    }
    
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
