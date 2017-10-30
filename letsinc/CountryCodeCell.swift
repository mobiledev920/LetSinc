//
//  CountryCodeCell.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 09/07/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class CountryCodeCell: UITableViewCell {

    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
