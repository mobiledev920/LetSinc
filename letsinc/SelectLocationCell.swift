//
//  SelectLocationCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 28/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import GooglePlaces

class SelectLocationCell: UITableViewCell {

    @IBOutlet weak var locationImageView: LSImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        locationImageView.activityIndicator.activityIndicatorViewStyle = .gray
        self.locationImageView.layer.cornerRadius = self.locationImageView.frame.size.height / 4
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    public func setData(data:GMSAutocompletePrediction) {
//        self.cityNameLabel.attributedText = data.attributedPrimaryText
//        self.countryNameLabel.attributedText = data.attributedSecondaryText
//        
//        self.locationImageView.loadImage(placeID: data.placeID!)
//    }
    
    public func setData(data:AnyObject) {
        if let cityName = ((data["structured_formatting"] as AnyObject)["main_text"]) as? String {
            self.cityNameLabel.text = cityName
        }
        
        if let countryName = ((data["structured_formatting"] as AnyObject)["secondary_text"]) as? String {
            self.countryNameLabel.text = countryName
        }
        
        
        let placeId = data["place_id"] as! String
        
        self.locationImageView.loadImage(placeID: placeId)
    }
    


}
