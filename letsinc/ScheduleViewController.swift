//
//  ScheduleViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SVProgressHUD

class ScheduleViewController: UIViewController {

    static let kDefaultHeaderViewHeight: CGFloat = 40.0
    
    static func storyboardInstance() -> ScheduleViewController? {
        let storyboard = UIStoryboard(name: String(describing: ScheduleViewController.self),
                                      bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: ScheduleViewController.self)) as?
        ScheduleViewController
    }
    
    
    @IBOutlet weak var noEventsDisplayContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    var tableData = [String:[Event]]()
    var sectionNames = [String]()
    let formatter = DateFormatter()
    var ignoreNextDataChange:Bool = false
    var selectedUser:User?
    var currentEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Graphik-Regular", size: 17)!,
            NSForegroundColorAttributeName : UIColor(rgb:0x4A4D52)
        ]

        if selectedUser == nil {
            // BARBUTTON: ADD +
            self.title = "My Schedule"
            let button = UIButton(type: .system)
            button.setImage(#imageLiteral(resourceName: "plus-icon"), for: .normal)
            button.setTitle("Add", for: .normal)
            button.titleLabel?.font = UIFont(name: "Graphik-Regular", size: 17)
            button.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0)
            button.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
            button.backgroundColor = UIColor(rgb: 0x40c4ea)
            button.tintColor = UIColor.white
            button.contentEdgeInsets = UIEdgeInsetsMake(3, 15, 5, 15)
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.sizeToFit()
            
            button.layer.cornerRadius = button.frame.size.height / 2
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            button.addTarget(self, action: #selector(ScheduleViewController.onAddTriggered), for: .touchUpInside)
        }
        else {
        
            self.title = "\(self.selectedUser!.username)'s Schedule"
        }

        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = TimeZone(identifier: "GMT")
        formatter.locale = Calendar.current.locale
        
        self.tableView.register(UINib(nibName: String(describing: ScheduleHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: ScheduleHeaderView.self))
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleViewController.dataChanged), name: .events, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScheduleViewController.dataChanged), name: .users, object: nil)
        
        dataChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if DataManager.sharedInstance.users.count == 0 {
            self.tableView.isHidden = true
            self.noEventsDisplayContainer.isHidden = true
            SVProgressHUD.show()
        }
        else {
            dataChanged()
        }
    }
    
    func dataChanged() {
        if DataManager.sharedInstance.users.count != 0 {
            SVProgressHUD.dismiss()
        }
        
        if self.ignoreNextDataChange {
            self.ignoreNextDataChange = false
            return
        }
        
        self.tableData = [String:[Event]]()
        self.sectionNames = [String]()
        let user = selectedUser != nil ? selectedUser! : currentUser!
        let myEvents = DataManager.sharedInstance.events.filter({$0.userID == user.uid}).sorted { (event1, event2) -> Bool in
            return event1.startDate.compareByDay(date: event2.startDate) < 0
        }
        
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        let currentDate = Calendar.current.date(from: components)!
        
        var currentDay = Date()
        var currentEventDay = Date()
        var firstEvent:Event?
        currentEvent = nil
        
        let s = NSTimeZone.local.secondsFromGMT()
        let timeInterval = TimeInterval(s)
        currentEventDay = currentDay.addingTimeInterval(timeInterval)
        
        if (timeInterval < 0 && currentDay.withoutTime().compareByDay(date: currentEventDay.withoutTime()) > 0) || (timeInterval > 0 && currentDay.withoutTime().compareByDay(date: currentEventDay.withoutTime()) < 0) {//when timezone - and +
            currentDay = currentEventDay
        }
        
        // row to point to must have start-end between today, or earliest with date >= today if more than 1
        var firstSectionName:String?
        for event in myEvents {
            
            var month = event.startDate.monthFromDate()
            var monthName = formatter.monthSymbols[month - 1]
            var year = event.startDate.yearFromDate()
            var sectionName = "\(monthName) \(year)"
            
            if event.startDate.withoutTime().compareByDay(date: currentDay.withoutTime()) < 0 && event.endDate.withoutTime().compareByDay(date: currentDay.withoutTime()) >= 0 {  //for ongoing trip
                month = event.endDate.monthFromDate()
                monthName = formatter.monthSymbols[month - 1]
                year = event.startDate.yearFromDate()
                sectionName = "\(monthName) \(year)"
            }
            
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
        
        print("CURRENT EVENT IS NIL \(currentEvent == nil)")

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
        
        if myEvents.count == 0 && selectedUser == nil {
            self.tableView.isHidden = true
            self.noEventsDisplayContainer.isHidden = false
        }
        else {
            self.tableView.isHidden = false
            self.noEventsDisplayContainer.isHidden = true
        }
        self.tableView.reloadData()
       
        if let fsection = firstSectionName, let firstSectionIndex = self.sectionNames.index(of: fsection) {
            
            let indexPath = IndexPath(row: rowIndex, section: firstSectionIndex)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            self.tableView.layoutIfNeeded()
           
            if let headerView = self.tableView.cellForRow(at: indexPath) {
                //self.tableView.headerView(forSection: firstSectionIndex)!
                let headerRect = headerView.frame
                let contentHeight = self.tableView.contentSize.height
                let tableHeight = self.tableView.frame.size.height
                let difference = tableHeight - (contentHeight - headerRect.origin.y)
                if difference > 0 {
                    self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, difference, 0.0)
                }
                
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    @IBAction func onAddButtonTriggered(_ sender: UIButton) {
        self.onAddTriggered()
    }
    
    func onAddTriggered() {
        if let nextViewController =
            AddEventViewController.storyboardInstance() {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
extension ScheduleViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = self.sectionNames[section]
        return self.tableData[sectionName]!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("CELL FOR ROW AT \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ScheduleCell.self), for: indexPath) as! ScheduleCell
        let sectionName = self.sectionNames[indexPath.section]
        let cellData = self.tableData[sectionName]![indexPath.row]
        cell.cityNameLabel.text = cellData.location.cityName
        cell.countryNameLabel.text = cellData.location.countryName
        cell.locationImageView.loadImage(placeID: cellData.location.placeID)
        cell.schedule = cellData
        cell.delegate = self
        
        let likedList = cellData.likes.filter { (like) -> Bool in
            return like.byUserID == currentUser?.uid
        }
        
        cell.numLikeButton.setTitle(String(cellData.likes.count), for: .normal)
        
        if likedList.count > 0 {
            cell.likeButton.setImage(#imageLiteral(resourceName: "icon_like"), for: .normal)
        } else {
            cell.likeButton.setImage(#imageLiteral(resourceName: "icon_unlike"), for: .normal)
        }
        
        if cellData.uid == currentEvent?.uid {
            cell.contentView.backgroundColor = UIColor(rgb: 0x40C4EA, alpha: 0.35)
            print("SETTINB CURRENT EVENT BG COLOR")
        }
        else {
            cell.contentView.backgroundColor = UIColor.clear
        }
        
        let startDate = cellData.startDate
        let endDate = cellData.endDate
        
//        let startMonth = Calendar.current.component(.month, from: startDate)
//        let startDay = Calendar.current.component(.day, from: startDate)
//        
//        let endMonth = Calendar.current.component(.month, from: endDate)
//        let endDay = Calendar.current.component(.day, from: endDate)
        
        let startMonth = startDate.monthFromDate()
        let startDay = startDate.dayFromDate()
        
        let endMonth = endDate.monthFromDate()
        let endDay = endDate.dayFromDate()
        
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
        
        cell.dateRangeLabel.attributedText = attributedDateString
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("SELECTED")
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if let nextViewController =
            AllUsersInLocationViewController.storyboardInstance() {
            
            let sectionName = self.sectionNames[indexPath.section]
            let event = self.tableData[sectionName]![indexPath.row]
            
            nextViewController.location = event.location
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }

    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ScheduleViewController.kDefaultHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ScheduleHeaderView.self)) as! ScheduleHeaderView
        headerView.dateLabel.text = self.sectionNames[section]
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return selectedUser == nil
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "      ", handler:{action, indexpath in
            print("EDIT")
            let sectionName = self.sectionNames[indexPath.section]
            let event = self.tableData[sectionName]![indexPath.row]
            self.tableView.setEditing(false, animated: true)
            if let nextViewController =
                AddEventViewController.storyboardInstance() {
                
                nextViewController.startDate = event.startDate
                nextViewController.endDate = event.endDate
                nextViewController.location = event.location
                nextViewController.existingEvent = event
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        })
        var img: UIImage = #imageLiteral(resourceName: "edit-action-image")
        var imgSize: CGSize = img.size
        UIGraphicsBeginImageContextWithOptions(imgSize, true, img.scale)
        img.draw(in: CGRect(x: 0, y: 0, width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        editRowAction.backgroundColor = UIColor(patternImage: newImage)
        
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "      ", handler:{action, indexpath in
            
            let sectionName = self.sectionNames[indexPath.section]
            let event = self.tableData[sectionName]![indexPath.row]
            self.tableData[sectionName]!.remove(at: indexPath.row)
            
            if self.tableData[sectionName]!.count == 0
            {
                self.sectionNames.remove(at: indexPath.section)
                self.tableData.removeValue(forKey: sectionName)
                self.tableView.deleteSections([indexPath.section], with: .automatic)
               
            }
            else
            {
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            
            self.tableView.setEditing(false, animated: true)
            self.ignoreNextDataChange = true
            FirebaseAPI.sharedInstance.deleteEvent(eventID: event.uid)
            
        })
        
        img = #imageLiteral(resourceName: "delete-action-image")
        imgSize = img.size
        UIGraphicsBeginImageContextWithOptions(imgSize, true, img.scale)
        img.draw(in: CGRect(x: 0, y: 0, width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        deleteRowAction.backgroundColor = UIColor(patternImage: newImage)
        
        return [editRowAction, deleteRowAction]
    }
}

extension ScheduleViewController: ScheduleCellDelegate {
    func showLikedUsers(_ event: Event) {
        let nextViewController = LikedUsersViewController.storyboardInstance(event)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
}
