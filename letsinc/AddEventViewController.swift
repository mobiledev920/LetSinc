//
//  AddEventViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SwiftMessages
import SVProgressHUD

class AddEventViewController: UIViewController {
    
    public enum DateDialogType {
        case startDate
        case endDate
    }
    
    
    static func storyboardInstance() -> AddEventViewController? {
        let storyboard = UIStoryboard(name: String(describing: AddEventViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        AddEventViewController
    }

    @IBOutlet weak var selectCityLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addStartDateLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addEndDateLineHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    @IBOutlet weak var selectCityButton: UIButton!
    @IBOutlet weak var deleteEventButton: UIButton!

    let formatter = DateFormatter()
    var doneButton:UIButton?
    
    var startDate:Date?
    var endDate:Date?
    var location:Location?
    var existingEvent:Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = existingEvent != nil ? "Edit Event" : "Add Event"
        // BARBUTTON: DONE
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "done-check-mark-icon"), for: .normal)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont(name: "Graphik-Regular", size: 17)
        button.titleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0)
        
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        button.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(AddEventViewController.onDoneTriggered), for: .touchUpInside)
        self.doneButton = button
        self.doneButton!.isEnabled = false
        
        self.deleteEventButton.layer.cornerRadius = self.deleteEventButton.frame.size.height / 2
        self.deleteEventButton.layer.borderColor = UIColor.white.cgColor
        self.deleteEventButton.layer.borderWidth = 1
        self.deleteEventButton.layer.masksToBounds = true
        
        if existingEvent != nil {
        
            self.deleteEventButton.isHidden = false
        }
        else {
        
            self.deleteEventButton.isHidden = true
        }
        
        self.selectCityLineHeightConstraint.constant = 0.5
        self.addStartDateLineHeightConstraint.constant = 0.5
        self.addEndDateLineHeightConstraint.constant = 0.5
        
        if let startDate = startDate {
            let day = startDate.dayFromDate()
            let month = startDate.monthFromDate()
            let year = startDate.yearFromDate()
            self.startDateButton.setTitle("\(month)/\(day)/\(year)", for: .normal)
        }
        if let endDate = endDate {
            let day = endDate.dayFromDate()
            let month = endDate.monthFromDate()
            let year = endDate.yearFromDate()
            self.endDateButton.setTitle("\(month)/\(day)/\(year)", for: .normal)
        }
        
        if let location = location {
            let fullLocationName = "\(location.cityName), \(location.countryName)"
            self.selectCityButton.setTitle(fullLocationName, for: .normal)
        }
        
        self.checkIsDone()
        
    }
    
    func showSelectDateDialog(type:DateDialogType) {
  
        var type = type
        let view: SelectCalendarDateDialog = try! SwiftMessages.viewFromNib()
//        view.configureDropShadow()

        if type == .startDate {
        
            view.typeTitleLabel.text = "Start Date"
            if self.endDate != nil {
                view.startDate = Date()
            }
            else {
                view.startDate = Date()
            }
            
            view.preselectedDate = self.startDate
            
        }
        else if type == .endDate {
            view.typeTitleLabel.text = "End Date"
            if self.startDate != nil {
                view.startDate = self.startDate
            }
            else {
                view.startDate = Date()
            }
            
            view.preselectedDate = self.endDate
        }
        
        
        view.initialise()
        view.dataSelectedAction = { date in
            
            let s = NSTimeZone.local.secondsFromGMT()
            let timeInterval = TimeInterval(s)
            var selectedDate = Date()
            
            if timeInterval >= 0 {
                selectedDate = date.addingTimeInterval(timeInterval)
            } else {
                selectedDate = date
            }
            
           
            let day = selectedDate.dayFromDate()
            let month = selectedDate.monthFromDate()
            let year = selectedDate.yearFromDate()
            
            if type == .startDate {
                self.startDateButton.setTitle("\(month)/\(day)/\(year)", for: .normal)
                self.startDate = selectedDate.withoutTime()
                
                if self.endDate != nil && self.startDate!.compareByDay(date: self.endDate!) > 0{
                
                    self.endDate = nil
                    self.endDateButton.setTitle("Add End Date", for: .normal)
                    
                }
                
                if self.endDate == nil {
                    view.isUserInteractionEnabled = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        
                        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                            view.frame.origin.y = view.frame.origin.y + 100
                        }, completion: { (finished) in
                            view.typeTitleLabel.text = "End Date"
                            type = .endDate
                            view.startDate = self.startDate
                            view.preselectedDate = nil
//                            view.initialise()
                            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
                                view.frame.origin.y = view.frame.origin.y - 100
                            }, completion: { (finished) in
                                view.isUserInteractionEnabled = true
                            })
                        })
                        
                    }
                   
                }
                else {
                    SwiftMessages.hide()
                }
                
            }
            else if type == .endDate
            {
                self.endDateButton.setTitle("\(month)/\(day)/\(year)", for: .normal)
                self.endDate = selectedDate.withoutTime()
                SwiftMessages.hide()
            }
            
            self.checkIsDone()
        }

        
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        config.eventListeners.append() { event in
            if case .didHide = event {

            }
        }
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func enableStartEndDates() -> Bool {
        if self.startDate!.compareByDay(date: self.endDate!) < 0 {
            return true
        }
        else {
            return false
        }
    }
    
    @IBAction func onAddStartDateTriggered(_ sender: UIButton) {
        self.showSelectDateDialog(type: .startDate)
    }
    
    @IBAction func onAddEndDateTriggered(_ sender: UIButton) {
        self.showSelectDateDialog(type: .endDate)
        
    }
    
    @IBAction func onSelectCityTriggered(_ sender: UIButton) {
        if let nextViewController =
            SelectLocationViewController.storyboardInstance() {
            nextViewController.modalPresentationStyle = .overCurrentContext
            nextViewController.modalTransitionStyle = .coverVertical
            nextViewController.locationSelected = self.locatonSelected
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func onDeleteEventTriggered(_ sender: UIButton) {
        FirebaseAPI.sharedInstance.deleteEvent(eventID: existingEvent!.uid)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func locatonSelected( location:Location ) {
        let fullLocationName = "\(location.cityName), \(location.countryName)"
        self.selectCityButton.setTitle(fullLocationName, for: .normal)
        self.location = location
        self.checkIsDone()
    }
    
    func checkIsDone() {

        if self.location != nil && self.startDate != nil && self.endDate != nil {
            self.doneButton?.isEnabled = true
        }
        else
        {
            self.doneButton?.isEnabled = false
        }
    }
    
    func onDoneTriggered() {
        
        // check overlap with existing events
        var overlappingEvents = DataManager.sharedInstance.events.filter({$0.userID == currentUser!.uid && ($0.startDate.isBetweeenIninclusive(date: self.startDate!, andDate: self.endDate!) ||  $0.endDate.isBetweeenIninclusive(date: self.startDate!, andDate: self.endDate!))})
        
        if let event = existingEvent
        {
            overlappingEvents = overlappingEvents.filter({$0.uid != event.uid})
        }
        
//        var filtered = [Event]()
//        for event in overlappingEvents {
//        
//            // remove the ones that have same start date or end date
//            if event.startDate.compareByDay(date: self.endDate!) == 0 || event.endDate.compareByDay(date: self.startDate!) == 0{
//                // remove that event
//            }
//            else
//            {
//                filtered.append(event)
//            }
//        }
//        
//        overlappingEvents = filtered

        
        if overlappingEvents.count > 0 {
            print("OVERLAPPING EVENTS = \(overlappingEvents.count)  ::::: \(overlappingEvents)")
            let event = overlappingEvents.first!
            let startDay = event.startDate.dayFromDate()
            let startMonth = event.startDate.monthFromDate()
            let startYear = event.startDate.yearFromDate()
            
            let endDay = event.endDate.dayFromDate()
            let endMonth = event.endDate.monthFromDate()
            let endYear = event.endDate.yearFromDate()
            
            SVProgressHUD.showError(withStatus: "Overlap with existing schedule: \n\n \(startMonth)/\(startDay)/\(startYear) - \(endMonth)/\(endDay)/\(endYear) \n \(overlappingEvents.first!.location.cityName)")
            SVProgressHUD.dismiss(withDelay: 4.0)
            return
        }
        
       
      
        // save event and go back
        if let event = existingEvent {
            // edit event
            FirebaseAPI.sharedInstance.editEvent(eventID: event.uid, location: self.location!, startDate: self.startDate!, endDate: self.endDate!, likes: event.likes, byUser: currentUser!.uid)
        }
        else {
            // save new event
            FirebaseAPI.sharedInstance.createEvent(location: self.location!, startDate: self.startDate!, endDate: self.endDate!)
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
