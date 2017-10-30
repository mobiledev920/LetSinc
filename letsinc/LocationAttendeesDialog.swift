//
//  LocationAttendeesDialog.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SwiftMessages

class LocationAttendeesDialog: MessageView {

    
    @IBOutlet weak var headerDateLabel: UILabel!
    @IBOutlet weak var headerLeftLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerRightLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    
    var dataSelectedAction: (() -> Void)?
    
    var tableData = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.headerLeftLineHeightConstraint.constant = 0.5
        self.headerRightLineHeightConstraint.constant = 0.5
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let nib = UINib(nibName: String(describing: LocationAttendeesCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: String(describing: LocationAttendeesCell.self))
        
        
        tableData.append("dsa")
        tableData.append("dsa")
        tableData.append("dsa")
        tableData.append("dsa")
        tableData.append("dsa")
        
        self.tableView.reloadData()
        
    }
    

}

extension LocationAttendeesDialog : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LocationAttendeesCell.self), for: indexPath) as! LocationAttendeesCell
        cell.owner = tableView
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSelectedAction?()
    }
    
}
