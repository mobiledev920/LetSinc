//
//  RangeCalendarCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 17/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import JTAppleCalendar

class RangeCalendarCell: JTAppleCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIView!
    @IBOutlet weak var emptyBoxIndicator: UIView!
    @IBOutlet weak var singleDotContainer: UIView!
    @IBOutlet weak var doubleDotContainer: UIView!
    @IBOutlet weak var singleDot: UIView!
    @IBOutlet weak var doubleDotLeft: UIView!
    @IBOutlet weak var doubleDotRight: UIView!
    @IBOutlet weak var leftRangeIndicator: UIView!
    @IBOutlet weak var fullRangeIndicator: UIView!
    @IBOutlet weak var rightRangeIndicator: UIView!
    @IBOutlet weak var middleRangeIndicator: UIView!
    
    let myEventColor = UIColor(rgb: 0x40C4EA)
    let friendEventColor = UIColor(rgb: 0xe09149)
    
    var addedBorders:Bool = false
    var isDisplayingRangeIndicators = false
    var rightBorder:CALayer?
    var bottomBorder:CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
        self.selectionIndicator.layer.cornerRadius = self.selectionIndicator.frame.size.height / 2
        self.selectionIndicator.isHidden = true
        
        self.singleDot.layer.cornerRadius = self.singleDot.frame.size.height / 2
        self.singleDot.layer.borderWidth = 0.5
        self.singleDot.layer.borderColor = UIColor.white.cgColor
        self.doubleDotLeft.layer.cornerRadius = self.doubleDotLeft.frame.size.height / 2
        self.doubleDotLeft.layer.borderWidth = 0.5
        self.doubleDotLeft.layer.borderColor = UIColor.white.cgColor
        self.doubleDotRight.layer.cornerRadius = self.doubleDotRight.frame.size.height / 2
        self.doubleDotRight.layer.borderWidth = 0.5
        self.doubleDotRight.layer.borderColor = UIColor.white.cgColor
        
        self.doubleDotLeft.backgroundColor = myEventColor
        self.doubleDotRight.backgroundColor = friendEventColor
        
        self.singleDot.backgroundColor = friendEventColor
        
        self.doubleDotContainer.isHidden = true
        self.singleDotContainer.isHidden = true
        self.emptyBoxIndicator.isHidden = true
        
        self.leftRangeIndicator.isHidden = true
        self.fullRangeIndicator.isHidden = true
        self.rightRangeIndicator.isHidden = true
        self.middleRangeIndicator.isHidden = true
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !addedBorders {
            addedBorders = true
            self.rightBorder?.removeFromSuperlayer()
            self.bottomBorder?.removeFromSuperlayer()
            rightBorder = self.layer.addBorder(edge: .right, color: UIColor(rgb: 0xe9eaeb), thickness: 0.5)
            bottomBorder = self.layer.addBorder(edge: .bottom, color: UIColor(rgb: 0xe9eaeb), thickness: 0.5)
            
            self.layoutIfNeeded()
            
            self.leftRangeIndicator.roundCorners([.topLeft, .bottomLeft], radius: self.leftRangeIndicator.frame.size.height / 2 )
            self.rightRangeIndicator.roundCorners([.topRight, .bottomRight], radius: self.rightRangeIndicator.frame.size.height / 2 )
            self.fullRangeIndicator.roundCorners([.topRight, .bottomRight, .topLeft, .bottomLeft], radius: self.fullRangeIndicator.frame.size.height / 2 )
            
        }
    }
    
    func setFullRangeIndicator() {
        self.leftRangeIndicator.isHidden = true
        self.rightRangeIndicator.isHidden = true
        self.fullRangeIndicator.isHidden = false
        self.middleRangeIndicator.isHidden = true
//        self.selectionIndicator.isHidden = true
        self.isDisplayingRangeIndicators = true
    }
    
    func setLeftRangeIndicator() {
        self.leftRangeIndicator.isHidden = false
        self.rightRangeIndicator.isHidden = true
        self.fullRangeIndicator.isHidden = true
        self.middleRangeIndicator.isHidden = true
//        self.selectionIndicator.isHidden = true
        self.isDisplayingRangeIndicators = true
    }
    
    func setRightRangeIndicator() {
        self.leftRangeIndicator.isHidden = true
        self.rightRangeIndicator.isHidden = false
        self.fullRangeIndicator.isHidden = true
        self.middleRangeIndicator.isHidden = true
//        self.selectionIndicator.isHidden = true
        self.isDisplayingRangeIndicators = true
    }
    
    func setNoRangeIndicator() {
        self.leftRangeIndicator.isHidden = true
        self.rightRangeIndicator.isHidden = true
        self.fullRangeIndicator.isHidden = true
        self.middleRangeIndicator.isHidden = true
        self.isDisplayingRangeIndicators = false
    }
    
    func setMiddleRangeIndicator() {
        self.leftRangeIndicator.isHidden = true
        self.rightRangeIndicator.isHidden = true
        self.fullRangeIndicator.isHidden = true
        self.middleRangeIndicator.isHidden = false
//        self.selectionIndicator.isHidden = true
        self.isDisplayingRangeIndicators = true
    }
    
    func setHasBothEvents() {
        self.singleDotContainer.isHidden = true
        self.doubleDotContainer.isHidden = false
        
    }
    
    func setHasSingleEvent(isMyEvent:Bool) {
        self.singleDotContainer.isHidden = false
        self.doubleDotContainer.isHidden = true
        self.singleDot.backgroundColor = isMyEvent ? myEventColor : friendEventColor
    }
    
    func setHasNoEvents() {
        self.singleDotContainer.isHidden = true
        self.doubleDotContainer.isHidden = true
    }
}
