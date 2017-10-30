//
//  SelectDateDialog.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SwiftMessages

class SelectDateDialog: MessageView {

    @IBOutlet weak var dialogTitleLabel: UILabel!
    @IBOutlet weak var selectDatePicker: UIDatePicker!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectDatePicker.minimumDate = Date()
        
    }

}
