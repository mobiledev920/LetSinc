//
//  SelectCalendarDateDialog.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 05/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SwiftMessages
import JTAppleCalendar

class SelectCalendarDateDialog: MessageView {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var selectedEventContainer: UIView!
    @IBOutlet weak var selectedEventCityNameLabel: UILabel!
    @IBOutlet weak var selectedEventCountryNameLabel: UILabel!
    @IBOutlet weak var selectedEventDateLabel: UILabel!
    @IBOutlet weak var selectedEventLocationImageView: LSImageView!
    @IBOutlet weak var selectedEventTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelContainer: UIView!
    @IBOutlet weak var typeTitleLabel: UILabel!
    
    
    var dataSelectedAction: ((Date) -> Void)?
    
    let formatter = DateFormatter()
    let monthSize = MonthSize(defaultSize: 45)
    var startDate:Date?
    var preselectedDate:Date?
    
    var myEvents = [Event]()
    
    
    var leftPreselectedIndexPaths = [IndexPath]()
    var fullPreselectedIndexPaths = [IndexPath]()
    var middlePreselectedIndexPaths = [IndexPath]()
    var rightPreselectedIndexPaths = [IndexPath]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NotificationCenter.default.addObserver(self, selector: #selector(SelectCalendarDateDialog.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
     
    }
    
    func initialise()  {
        
        self.selectedEventContainer.layer.cornerRadius = self.selectedEventContainer.frame.size.height / 4
        self.titleLabelContainer.layer.cornerRadius = 5
        self.selectedEventLocationImageView.layer.cornerRadius = self.selectedEventLocationImageView.frame.size.height / 4
        
        self.calendarView.calendarDelegate = self
        self.calendarView.calendarDataSource = self
        
        self.calendarView.register(UINib(nibName: String(describing: RangeCalendarCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: RangeCalendarCell.self))
        
        self.calendarView.register(UINib(nibName: String(describing: CalendarHeaderView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: CalendarDialogHeaderView.self))
        
        
        self.calendarView.minimumLineSpacing = 0
        self.calendarView.minimumInteritemSpacing = 0
        self.calendarView.allowsMultipleSelection = false
        self.calendarView.isRangeSelectionUsed = false
        
        self.calendarView.deselectAllDates(triggerSelectionDelegate: false)
        
        
        self.myEvents = DataManager.sharedInstance.events.filter({$0.userID == currentUser!.uid}).sorted { (event1, event2) -> Bool in
            return event1.startDate.compareByDay(date: event2.startDate) < 0
        }
        
        self.isUserInteractionEnabled = false
       
         self.calendarView.reloadData { 
        
            if let date = self.preselectedDate {
                self.calendarView.scrollToDate(date)
                let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.calendarView.selectDates([date], triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                    self.isUserInteractionEnabled = true
                }
                
            }
            else {
                self.isUserInteractionEnabled = true
            }
        }
        
    }
    
    deinit {
        print("DEINIIIT")
        NotificationCenter.default.removeObserver(self)
    }
    
    func rotated() {
        self.calendarView.reloadData()
    }
    
    func isAmongExistingEventDates(date:Date) -> Bool {
        return self.myEvents.filter({date.isBetweeen(date: $0.startDate, andDate: $0.endDate)}).first != nil
    }
    
    func displayExistingEvent(event:Event) {
        
        self.selectedEventLocationImageView.loadImage(placeID: event.location.placeID)
        self.selectedEventCityNameLabel.text = event.location.cityName
        self.selectedEventCountryNameLabel.text = event.location.countryName
        
        let startMonth = Calendar.current.component(.month, from: event.startDate)
        let startDay = Calendar.current.component(.day, from: event.startDate)
        
        let endMonth = Calendar.current.component(.month, from: event.endDate)
        let endDay = Calendar.current.component(.day, from: event.endDate)
        
        self.selectedEventDateLabel.text = "\(String(format: "%02d", startDay))/\(String(format: "%02d", startMonth)) - \(String(format: "%02d", endDay))/\(String(format: "%02d", endMonth))"
        
        self.selectedEventTopConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
    }
    @IBAction func onDismissExistingEventTriggered(_ sender: Any) {
        self.dismissBubble()
    }
    
    func dismissBubble() {
        self.selectedEventTopConstraint.constant = 70
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    @IBAction func onDismissButtonTriggered(_ sender: Any) {
        SwiftMessages.hide()
    }
}

extension SelectCalendarDateDialog : JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func handleCellTextColor(cell:RangeCalendarCell, state:CellState) {
        
        if state.isSelected {
            if cell.isDisplayingRangeIndicators {
                cell.dateLabel.textColor = UIColor(rgb: 0x4A4D52)
            }
            else {
                cell.dateLabel.textColor = UIColor.white
            }
            
        } else {
            if state.dateBelongsTo == .thisMonth && state.date.compareByDay(date: self.startDate!) >= 0  {
                cell.dateLabel.textColor = UIColor(rgb: 0x4A4D52)
            } else {
                cell.dateLabel.textColor = UIColor(rgb: 0xC8C9CB)
            }
        }
    }
    
    func handleCellSelected(cell:RangeCalendarCell, state:CellState) {
        if state.isSelected {
            cell.selectionIndicator.isHidden = false
        } else {
            cell.selectionIndicator.isHidden = true
        }
        
    }
    
    func handleCellVisibility(cell:RangeCalendarCell, state:CellState) {
        if state.dateBelongsTo != .thisMonth {
            cell.emptyBoxIndicator.isHidden = false
            cell.dateLabel.isHidden = true
            cell.selectionIndicator.isHidden = true
            cell.doubleDotContainer.isHidden = true
            cell.singleDotContainer.isHidden = true
            cell.setNoRangeIndicator()
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
    
    func handleCellRangeIndicator(cell:RangeCalendarCell, state:CellState, indexPath:IndexPath) {
        
        if isAmongExistingEventDates(date: state.date) {
            
            
            let event = self.myEvents.filter({state.date.isBetweeen(date: $0.startDate, andDate: $0.endDate)}).first!
            if event.startDate.compareByDay(date: event.endDate) == 0 {
                // event with single date
                cell.setFullRangeIndicator()
            }
            else {
            
                // event with multiple dates
                
                // check event has date before state.date
                // check event has date after state.date
                let hasBeforeDates = state.date.compareByDay(date: event.startDate) > 0
                let hasAfterDates = state.date.compareByDay(date: event.endDate) < 0
                if hasBeforeDates && hasAfterDates {
                    cell.setMiddleRangeIndicator()
                }
                else if hasBeforeDates && !hasAfterDates {
                    cell.setRightRangeIndicator()
                }
                else if !hasBeforeDates && hasAfterDates {
                    cell.setLeftRangeIndicator()
                }
                else {
                    cell.setMiddleRangeIndicator()
                }
                
                
            }
            
            
        }
        else {
            cell.setNoRangeIndicator()
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = self.startDate!
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate)!
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 4, calendar: nil, generateInDates: nil, generateOutDates: .tillEndOfRow, firstDayOfWeek: nil, hasStrictBoundaries: true)
        return parameters
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: String(describing: RangeCalendarCell.self), for: indexPath) as! RangeCalendarCell
        cell.dateLabel.text = cellState.text
        print("CELL IS SELECTED : \(cellState.isSelected)")
        handleCellSelected(cell: cell, state: cellState)
        self.handleCellRangeIndicator(cell: cell, state: cellState, indexPath: indexPath)
        
        handleCellTextColor(cell: cell, state: cellState)
        handleCellVisibility(cell: cell, state: cellState)
        
        cell.addedBorders = false
        cell.layoutSubviews()
        
        return cell
    }
  
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
  
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        
        let date = range.start
        let month = Calendar.current.component(.month, from: date)
        let monthName = formatter.monthSymbols[month - 1]
        let year = Calendar.current.component(.year, from: date)
        
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: String(describing: CalendarDialogHeaderView.self), for: indexPath) as! CalendarDialogHeaderView
        header.monthYearLabel.text = "\(monthName.uppercased()) \(year)"
        header.addedBorders = false
        header.layoutSubviews()
        header.layoutIfNeeded()
        return header
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
//        let isInExisting = isAmongExistingEventDates(date: date)
//        if isInExisting {
//            let event = self.myEvents.filter({date.isBetweeen(date: $0.startDate, andDate: $0.endDate)}).first!
//            self.displayExistingEvent(event: event)
//            return
//        }
        
        let cell = cell as! RangeCalendarCell
        handleCellTextColor(cell: cell, state: cellState)
        handleCellSelected(cell: cell, state: cellState)
        handleCellVisibility(cell: cell, state: cellState)
        
        if preselectedDate != nil {
            self.preselectedDate = nil
            return
        }
        
        
        dataSelectedAction?(cellState.date)
        
        
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
//        if  !isAmongExistingEventDates(date: date) || (cellState.date.compareByDay(date: self.startDate!) < 0 || cellState.dateBelongsTo != .thisMonth) {
//            print("RETURNING SHOULD SELECT FALSE")
//            return false
//        }
//        if  isAmongExistingEventDates(date: date) {
//            print("RETURNING SHOULD SELECT isAmongExistingEventDates FALSE")
//            return false
//        }
        if  cellState.date.compareByDay(date: self.startDate!) < 0 {
            return false
        }
        if  cellState.dateBelongsTo != .thisMonth {
            return false
        }
        
        return true
    }
    
//    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell, cellState: CellState) -> Bool {
//        
//        if let cell = cell as? RangeCalendarCell {
//            if cell.isDisplayingRangeIndicators {
//            
//                let event = self.myEvents.filter({date.isBetweeen(date: $0.startDate, andDate: $0.endDate)}).first!
//                print("DISPLAY BUBBLE")
//                self.displayExistingEvent(event: event)
//                return false
//            }
//            else
//            {
//                return true
//            }
//            
//        }
//    
//        return true
//    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let cell = cell as? RangeCalendarCell {
            handleCellTextColor(cell: cell, state: cellState)
            handleCellSelected(cell:cell, state: cellState)
            handleCellVisibility(cell: cell, state: cellState)
        }
        
        

    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return monthSize
    }
    
}
