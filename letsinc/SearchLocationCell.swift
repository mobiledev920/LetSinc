//
//  SearchLocationCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 12/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class SearchLocationCell: UITableViewCell {

    @IBOutlet weak var userImageView: LSImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userLocationLabelContainer: UIView!
    
    let formatter = DateFormatter()
    
    var imageTriggered:((UITableViewCell)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 4
        self.userLocationLabelContainer.layer.cornerRadius = self.userLocationLabelContainer.frame.size.height / 2
    }
    
    func setData(event:Event)  {
        
        let user = userByUID(userUID: event.userID)
        self.userImageView.loadImage(url: user.imageURL)
        
        self.usernameLabel.text = user.username
        self.userLocationLabel.text = user.currentLocation
        

        let startMonth = event.startDate.monthFromDate()
        let startDay = event.startDate.dayFromDate()
        
        let endMonth = event.endDate.monthFromDate()
        let endDay = event.endDate.dayFromDate()
        
        var dayExtension = "th"
        let endDayLastDigit = endDay % 10
        if endDayLastDigit == 1 {
            dayExtension = "st"
        } else if endDayLastDigit == 2 {
            dayExtension = "nd"
        } else if endDayLastDigit == 3 {
            dayExtension = "rd"
        }
        
        
        
        let attributes = [NSFontAttributeName : UIFont(name: "Graphik-Regular", size: 18), NSForegroundColorAttributeName : UIColor.white]
        let attributedDateString = NSMutableAttributedString(string: "\(startDay) - \(endDay)", attributes: attributes as Any as? [String : Any])
        
        let dayExtensionAttributes = [NSFontAttributeName : UIFont(name: "Graphik-Regular", size: 15), NSForegroundColorAttributeName : UIColor.white]
        let dayExtensionString = NSMutableAttributedString(string: "\(dayExtension)", attributes: dayExtensionAttributes as Any as? [String : Any])
        
        attributedDateString.append(dayExtensionString)
        
        if startMonth != endMonth {
            
            var monthName = formatter.monthSymbols[endMonth-1].uppercased()
            monthName = monthName.substring(to:monthName.index(monthName.startIndex, offsetBy: 3))
            let monthAttributes = [NSFontAttributeName : UIFont(name: "Graphik-Regular", size: 10), NSForegroundColorAttributeName : UIColor(rgb: 0xc9d0d3)]
            let monthAttributedString = NSMutableAttributedString(string: " \(monthName)", attributes: monthAttributes as Any as? [String : Any])
            attributedDateString.append(monthAttributedString)
            
        }
        
        self.dateLabel.attributedText = attributedDateString
        
//        let startMonth = Calendar.current.component(.month, from: event.startDate)
//        let startDay = Calendar.current.component(.day, from: event.startDate)
//        
//        let endMonth = Calendar.current.component(.month, from: event.endDate)
//        let endDay = Calendar.current.component(.day, from: event.endDate)
//        
//        self.dateLabel.text = "\(String(format: "%02d", startDay))/\(String(format: "%02d", startMonth)) - \(String(format: "%02d", endDay))/\(String(format: "%02d", endMonth))"
    }
    @IBAction func onUserImageTriggered(_ sender: UIButton) {
        self.imageTriggered?(self)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
