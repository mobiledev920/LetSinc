//
//  CalendarCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIView!
    
    @IBOutlet weak var singleDotContainer: UIView!
    @IBOutlet weak var doubleDotContainer: UIView!
    @IBOutlet weak var singleDot: UIView!
    @IBOutlet weak var doubleDotLeft: UIView!
    @IBOutlet weak var doubleDotRight: UIView!
    @IBOutlet weak var emptyBoxIndicator: UIView!
    @IBOutlet weak var currentDayIndicator: UIView!
    
    let myEventColor = UIColor(rgb: 0x40C4EA)
    let friendEventColor = UIColor(rgb: 0xe09149)
    let bothEventsColor = UIColor(rgb: 0x3FC380)
    
    var addedBorders:Bool = false
    var rightBorder:CALayer?
    var bottomBorder:CALayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionIndicator.layer.cornerRadius = self.selectionIndicator.frame.size.height / 2
        self.currentDayIndicator.layer.cornerRadius = self.currentDayIndicator.frame.size.height / 2
        self.currentDayIndicator.isHidden = true
        
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
        
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !addedBorders {
            addedBorders = true
            self.rightBorder?.removeFromSuperlayer()
            self.bottomBorder?.removeFromSuperlayer()
            
            self.rightBorder = self.layer.addBorder(edge: .right, color: UIColor(rgb: 0xe9eaeb, alpha: 0.2), thickness: 0.5)
            self.bottomBorder = self.layer.addBorder(edge: .bottom, color: UIColor(rgb: 0xe9eaeb, alpha: 0.2), thickness: 0.5)
        }
    }
    
    override func willTransition(from oldLayout: UICollectionViewLayout, to newLayout: UICollectionViewLayout) {
        print("VIEW WILL TRANSITION")
    }
    
    func setHasBothEvents() {
        self.singleDot.backgroundColor = bothEventsColor
        self.singleDotContainer.isHidden = false
        self.doubleDotContainer.isHidden = true
        
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
