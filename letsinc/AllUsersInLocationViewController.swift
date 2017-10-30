//
//  AllUsersInLocationViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 27/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class AllUsersInLocationViewController: UIViewController {

    static func storyboardInstance() -> AllUsersInLocationViewController? {
        let storyboard = UIStoryboard(name: String(describing: AllUsersInLocationViewController.self),
                                      bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: AllUsersInLocationViewController.self)) as?
        AllUsersInLocationViewController
    }
    
    static let kDefaultHeaderViewHeight: CGFloat = 40.0
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var locationImageView: LSImageView!
    
    var tableData = [String:[Event]]()
    var sectionNames = [String]()
    let formatter = DateFormatter()
    let currentDay = Date()
    var currentEvent:Event?
    
    var location:Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Graphik-Regular", size: 17)!,
            NSForegroundColorAttributeName : UIColor(rgb:0x4A4D52)
        ]
        
        self.title = "\(self.location!.cityName)"
        self.locationImageView.loadImage(placeID: self.location!.placeID)
        self.locationNameLabel.text = self.location!.cityName
        
        self.tableView.register(UINib(nibName: String(describing: ScheduleHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: ScheduleHeaderView.self))
        
        self.dataChanged()
    }

    func dataChanged() {
        self.tableData = [String:[Event]]()
        self.sectionNames = [String]()
        
        let events = DataManager.sharedInstance.events.filter({isFriend(userID: $0.userID) && $0.location.placeID == location!.placeID}).sorted { (event1, event2) -> Bool in
            return event1.startDate.compareByDay(date: event2.startDate) < 0
        }       
        
        
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        let currentDate = Calendar.current.date(from: components)!
//        let currentDate = Date()

        var firstSectionName:String?
        
        var firstEvent:Event?
        
        for event in events {
            let date = event.startDate
            
            let month = date.monthFromDate()
            let monthName = formatter.monthSymbols[month-1]
            let year = date.yearFromDate()
            
            let sectionName = "\(monthName) \(year)"
            
            if self.tableData[sectionName] == nil {
                self.tableData[sectionName] = [Event]()
                self.sectionNames.append(sectionName)
            }
            self.tableData[sectionName]!.append(event)
            
            if event.startDate.withoutTime().compareByDay(date: currentDate) >= 0 && firstSectionName == nil {
                firstSectionName = sectionName
            }
            
            if (currentDay.withoutTime().isBetweeen(date: event.startDate.withoutTime(), andDate: event.endDate.withoutTime()) || event.startDate.withoutTime().compareByDay(date: currentDay.withoutTime()) > 0) && firstEvent == nil  {
                firstEvent = event
            }
            
            if (currentDay.withoutTime().isBetweeenIninclusive(date: event.startDate.withoutTime(), andDate: event.endDate.withoutTime()) || currentDay.withoutTime().compareByDay(date: event.startDate.withoutTime()) == 0 || currentDay.withoutTime().compareByDay(date: event.endDate.withoutTime()) == 0) && currentEvent == nil  {
                currentEvent = event
            }
        }
        
        var rowIndex = 0
        
        if let _ = currentEvent {
            firstEvent = currentEvent
        }
        if let e = firstEvent, let fSection = firstSectionName {
            if let rIndex = self.tableData[fSection]!.index(where: { (item) -> Bool in
                item.uid == e.uid
            }){
                
                rowIndex = rIndex
            }
            
        }
        
        self.tableView.reloadData()
        
        if let fsection = firstSectionName, let firstSectionIndex = self.sectionNames.index(of: fsection) {
            
            let indexPath = IndexPath(row: rowIndex, section: firstSectionIndex)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            self.tableView.layoutIfNeeded()
//            
            if let headerView = self.tableView.cellForRow(at: indexPath) {
                //self.tableView.headerView(forSection: firstSectionIndex)!
                let headerRect = headerView.frame
                let contentHeight = self.tableView.contentSize.height
                let tableHeight = self.tableView.frame.size.height
                let difference = tableHeight - (contentHeight - headerRect.origin.y)
                if difference > 0 {
                    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, difference, 0.0)
                }
                
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
        
        
    }
    
    func userImageTriggered(cell:UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let sectionName = self.sectionNames[indexPath.section]
        let cellData = self.tableData[sectionName]![indexPath.row]
        let selectedUser = userByUID(userUID: cellData.userID)
        
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = selectedUser.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
            
            
        }
        
    }
}

extension AllUsersInLocationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = self.sectionNames[section]
        return self.tableData[sectionName]!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchLocationCell.self), for: indexPath) as! SearchLocationCell
        let sectionName = self.sectionNames[indexPath.section]
        let cellData = self.tableData[sectionName]![indexPath.row]
        cell.imageTriggered = self.userImageTriggered
        
        if cellData.uid == currentEvent?.uid {
            cell.contentView.backgroundColor = UIColor(rgb: 0x40C4EA, alpha: 0.35)
            print("SETTINB CURRENT EVENT BG COLOR")
        }
        else {
            cell.contentView.backgroundColor = UIColor.clear
        }
        cell.setData(event: cellData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionName = self.sectionNames[indexPath.section]
        let cellData = self.tableData[sectionName]![indexPath.row]
        let selectedUser = userByUID(userUID: cellData.userID)
        if selectedUser.uid == currentUser!.uid {
            self.tabBarController!.selectedIndex = 1
            return
        }
        
        if let nextViewController =
            ScheduleViewController.storyboardInstance() {
            nextViewController.selectedUser = selectedUser
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return AllUsersInLocationViewController.kDefaultHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ScheduleHeaderView.self)) as! ScheduleHeaderView
        headerView.dateLabel.text = self.sectionNames[section]
        return headerView
        
    }

    
}

