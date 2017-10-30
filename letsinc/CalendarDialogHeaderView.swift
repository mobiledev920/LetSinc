//
//  CalendarHeaderView.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarDialogHeaderView: JTAppleCollectionReusableView {
    
    @IBOutlet weak var monthYearLabel: UILabel!
    @IBOutlet weak var sunLabel: UILabel!
    @IBOutlet weak var monLabel: UILabel!
    @IBOutlet weak var tueLabel: UILabel!
    @IBOutlet weak var wedLabel: UILabel!
    @IBOutlet weak var thuLabel: UILabel!
    @IBOutlet weak var friLabel: UILabel!
    @IBOutlet weak var satLabel: UILabel!
    
    var addedBorders:Bool = false
    var borders = [CALayer]()
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        if !addedBorders {
            addedBorders = true
            for border in borders { border.removeFromSuperlayer() }
            self.addBorderFull(label: self.sunLabel)
            self.addBorderExceptLeft(label: self.monLabel)
            self.addBorderExceptLeft(label: self.tueLabel)
            self.addBorderExceptLeft(label: self.wedLabel)
            self.addBorderExceptLeft(label: self.thuLabel)
            self.addBorderExceptLeft(label: self.friLabel)
            self.addBorderExceptLeft(label: self.satLabel)
        }
        
    }
    
    
    
    
    func addBorderFull(label:UILabel) {
        let borderColor = UIColor(rgb: 0xe9eaeb)
        let thickness:CGFloat = 0.5
        
        borders.append( label.layer.addBorder(edge: .top, color: borderColor, thickness: thickness) )
        borders.append( label.layer.addBorder(edge: .right, color: borderColor, thickness: thickness) )
        borders.append( label.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness) )
        borders.append( label.layer.addBorder(edge: .left, color: borderColor, thickness: thickness) )
    }
    
    func addBorderExceptLeft(label:UILabel) {
        let borderColor = UIColor(rgb: 0xe9eaeb)
        let thickness:CGFloat = 0.5
        
        borders.append( label.layer.addBorder(edge: .top, color: borderColor, thickness: thickness) )
        borders.append( label.layer.addBorder(edge: .right, color: borderColor, thickness: thickness) )
        borders.append( label.layer.addBorder(edge: .bottom, color: borderColor, thickness: thickness) )
        
    }
}
