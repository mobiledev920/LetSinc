//
//  CalendarViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import JTAppleCalendar
import SwiftMessages
import Firebase
import SVProgressHUD

class CalendarViewController: UIViewController {

    static func storyboardInstance() -> UINavigationController? {
        let storyboard = UIStoryboard(name: String(describing: CalendarViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        UINavigationController
    }
    
    static var historyDate:Date?
    
    @IBOutlet weak var dividerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var attendeesTableView: UITableView!
    
    let formatter = DateFormatter()
    let monthSize = MonthSize(defaultSize: 65)
    
    var tableData = [LocationAttendees]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Graphik-Regular", size: 17)!,
            NSForegroundColorAttributeName : UIColor(rgb:0x4A4D52)
        ]

        self.dividerHeightConstraint.constant = 0.5
        self.calendarView.minimumLineSpacing = 0
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.isMultipleTouchEnabled = false
        self.calendarView.allowsMultipleSelection = false
        
//        calendarView.selectDates([Date()])
        print("CALENDAR VIEW DID LOAD")
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.dataChanged), name: .events, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.dataChanged), name: .users, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.dataChanged), name: .friendships, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CalendarViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        if DataManager.sharedInstance.users.count == 0 {
            SVProgressHUD.show()
        }
        
    }
    
    func rotated() {
        
        self.calendarView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
            if let date = CalendarViewController.historyDate  {
//                self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: UICollectionViewScrollPosition.centeredVertically, extraAddedOffset: 0.0, completionHandler: {
//                    DispatchQueue.main.asyncAfter(deadline: .now()) {
//                        self.calendarView.layoutSubviews()
//                        self.calendarView.selectDates([date])
//                    }
//                    
//                })
                self.calendarView.scrollToHeaderForDate(date, triggerScrollToDateDelegate: false, withAnimation: false, extraAddedOffset: 0.0, completionHandler: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.calendarView.layoutSubviews()
                        self.calendarView.selectDates([date])
                    }
                })
                
            }
            else {
                let date = Date()
//                self.calendarView.scrollToDate(date, triggerScrollToDateDelegate: false, animateScroll: false, preferredScrollPosition: UICollectionViewScrollPosition.centeredVertically, extraAddedOffset: 0.0, completionHandler: {
//                    DispatchQueue.main.asyncAfter(deadline: .now()) {
//                        self.calendarView.layoutSubviews()
//                        self.calendarView.selectDates([date])
//                    }
//                    
//                })
                self.calendarView.scrollToHeaderForDate(date, triggerScrollToDateDelegate: false, withAnimation: false, extraAddedOffset: 0.0, completionHandler: {
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.calendarView.layoutSubviews()
                        self.calendarView.selectDates([date])
                    }
                })
                
                
                
            }
            self.dataChanged()
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.calendarView.deselectAllDates()
    }
    
    func dataChanged() {
        print("data changed")
        if let selectedDate = calendarView.selectedDates.first {
            print("has selected date")
            self.tableData = getLocationAttendeesFor(date: selectedDate)
            self.attendeesTableView.reloadData()
        }
        if DataManager.sharedInstance.users.count != 0 {
            SVProgressHUD.dismiss()
        }
        
        self.calendarView.reloadData()

        
    }
    
    func userImageTriggered(cell:UITableViewCell) {
        let indexPath = self.attendeesTableView.indexPath(for: cell)!
        let cellData = self.tableData[indexPath.row]
        
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = cellData.attendees.first!.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
            
            
        }
        
    }
   
//    func showDialog(date:Date) {
//        let view: LocationAttendeesDialog = try! SwiftMessages.viewFromNib()
//        view.configureDropShadow()
//        view.dataSelectedAction = {
//            SwiftMessages.hide()
//            if let nextViewController =
//                LocationAttendeesViewController.storyboardInstance() {
//                self.navigationController?.pushViewController(nextViewController, animated: true)
//            }
//        }
//        let day = Calendar.current.component(.day, from: date)
//        let month = Calendar.current.component(.month, from: date)
//        let monthName = formatter.monthSymbols[month-1]
//        let year = Calendar.current.component(.year, from: date)
//        
//        view.headerDateLabel.text = "\(monthName) \(day), \(year)"
////        view.getTacosAction = { _ in SwiftMessages.hide() }
////        view.cancelAction = { SwiftMessages.hide() }
//        var config = SwiftMessages.defaultConfig
//        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
//        config.duration = .forever
//        config.presentationStyle = .bottom
//        config.dimMode = .gray(interactive: true)
//        config.eventListeners.append() { event in
//            if case .didHide = event {
//               self.calendarView.deselectAllDates(triggerSelectionDelegate: false)
//            }
//        }
//        SwiftMessages.show(config: config, view: view)
//    }

}


extension CalendarViewController : JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    /// Implement the function to configure calendar cells. The code that will go in here is the same
    /// that you will code for your cellForItem function. This function is only called to address
    /// inconsistencies in the visual appearance as stated by Apple: https://developer.apple.com/documentation/uikit/uicollectionview/1771771-prefetchingenabled
    /// a date-cell. This is the point of customization for your date cells
    /// - Parameters:
    ///     - calendar: The JTAppleCalendar view giving this information.
    ///     - cell: The cell
    ///     - date: date attached to the cell
    ///     - cellState: The month the date-cell belongs to.
    ///     - indexPath: use this value when dequeing cells
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
    }


    func handleCellTextColor(cell:CalendarCell, state:CellState) {
        
        if state.isSelected {
            cell.dateLabel.textColor = UIColor.white
        } else {
            if state.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = UIColor.white//UIColor(rgb: 0x4A4D52)
            } else {
                cell.dateLabel.textColor = UIColor(rgb: 0xC8C9CB)
            }
        }
    }
    
    func handleCellSelected(cell:CalendarCell, state:CellState) {

        if state.isSelected {
            cell.selectionIndicator.isHidden = false
        } else {
            cell.selectionIndicator.isHidden = true
        }
    }
    
    func handleCellVisibility(cell:CalendarCell, state:CellState) {
        if state.dateBelongsTo != .thisMonth {
            cell.emptyBoxIndicator.isHidden = false
            cell.dateLabel.isHidden = true
            cell.selectionIndicator.isHidden = true
            cell.doubleDotContainer.isHidden = true
            cell.singleDotContainer.isHidden = true
        }
        else {
            cell.emptyBoxIndicator.isHidden = true
            cell.dateLabel.isHidden = false
            if state.isSelected {
                cell.selectionIndicator.isHidden = false
            }
            else {
                cell.selectionIndicator.isHidden = true
            }
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let s = NSTimeZone.local.secondsFromGMT()
        let timeInterval = TimeInterval(s)
        
        var startDate = Date().addingTimeInterval(timeInterval)
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!.addingTimeInterval(timeInterval)
        startDate = Calendar.current.date(byAdding: .year, value: -1, to: startDate)!.addingTimeInterval(timeInterval)
        
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 4, calendar: nil, generateInDates: nil, generateOutDates: .tillEndOfRow, firstDayOfWeek: nil, hasStrictBoundaries: true)
        
        return parameters
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        
//        let s = NSTimeZone.local.secondsFromGMT()
//        let timeInterval = TimeInterval(s)
//        let localCellDate = cellState.date.addingTimeInterval(timeInterval)
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: String(describing: CalendarCell.self), for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleCellTextColor(cell: cell, state: cellState)
        handleCellSelected(cell: cell, state: cellState)
        
        if cellState.date.compareByDay(date: Date()) == 0 && cellState.dateBelongsTo == .thisMonth {
            cell.currentDayIndicator.isHidden = false
        }
        else {
            cell.currentDayIndicator.isHidden = true
        }
        
        let events = DataManager.sharedInstance.events.filter({ cellState.date.isBetweeen(date: $0.startDate, andDate: $0.endDate) && ($0.userID == currentUser!.uid || isFriend(userID: $0.userID)) })
        
        if events.count > 0
        {
            // check has personal events
            let personalEvent = events.filter({$0.userID == currentUser!.uid}).first
            let friendEvent = events.filter({$0.userID != currentUser!.uid}).first
            if personalEvent != nil && friendEvent != nil {
                cell.setHasBothEvents()
            }
            else if personalEvent != nil {
                cell.setHasSingleEvent(isMyEvent: true)
            }
            else if friendEvent != nil {
                cell.setHasSingleEvent(isMyEvent: false)
            }
        }
        else {
            cell.setHasNoEvents()
        }
        
        cell.addedBorders = false
        cell.layoutSubviews()
        
        handleCellVisibility(cell: cell, state: cellState)

        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        
        let date = range.start
        let month = Calendar.current.component(.month, from: date)
        let monthName = formatter.monthSymbols[month-1]
        let year = Calendar.current.component(.year, from: date)
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: String(describing: CalendarHeaderView.self), for: indexPath) as! CalendarHeaderView
        header.monthYearLabel.text = "\(monthName) \(year)"
        header.addedBorders = false
        header.layoutSubviews()
        header.layoutIfNeeded()
        return header
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        calendar.deselectAllDates()
        handleCellTextColor(cell: cell as! CalendarCell, state: cellState)
        handleCellSelected(cell: cell as! CalendarCell, state: cellState)
        handleCellVisibility(cell: cell as! CalendarCell, state: cellState)
        
        
        let adjustedDate = Calendar.current.date(byAdding: .day, value: 0, to: cellState.date)
        
//        self.tableData = getLocationAttendeesFor(date: cellState.date)
        
//        let s = NSTimeZone.local.secondsFromGMT()
//        let timeInterval = TimeInterval(s)       
        
        self.tableData = getLocationAttendeesFor(date: adjustedDate!.withoutTime())
        
        self.attendeesTableView.reloadData()
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let cell = cell
        {
            handleCellTextColor(cell: cell as! CalendarCell, state: cellState)
            handleCellSelected(cell: cell as! CalendarCell, state: cellState)
        }
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
        if cellState.dateBelongsTo != .thisMonth {
            return false
        }
        else {
            return true
        }
        
    }
    
}

extension CalendarViewController : UITableViewDelegate, UITableViewDataSource {
    
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
        cell.imageTriggered = self.userImageTriggered
        let cellData = self.tableData[indexPath.row]
        cell.setData(locationAttendees: cellData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let nextViewController =
            LocationAttendeesViewController.storyboardInstance() {
            let locationAttendees = self.tableData[indexPath.row]
            nextViewController.locationAttendees = locationAttendees
            CalendarViewController.historyDate = self.calendarView.selectedDates.first
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
}
