//
//  LocationAttendeesViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 21/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class LocationAttendeesViewController: UIViewController {

    static func storyboardInstance() -> LocationAttendeesViewController? {
        let storyboard = UIStoryboard(name: String(describing: LocationAttendeesViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        LocationAttendeesViewController
    }
    
    @IBOutlet weak var locationImageView: LSImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateLabelContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let currentDay = Date()
    var currentEvent : Event?
//    var lastEvent : Event?

    var locationAttendees:LocationAttendees?
    
    var tableData = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.dateLabelContainer.layer.cornerRadius = self.dateLabelContainer.frame.size.height / 2
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MM yyyy"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale

        
        let date = locationAttendees!.date
        let month = Calendar.current.component(.month, from: date)
        let monthName = formatter.monthSymbols[month-1]
        let day = Calendar.current.component(.day, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        
        self.locationLabel.text = locationAttendees!.location.cityName
        self.dateLabel.text = "\(monthName.uppercased()) \(day), \(year)"
//        self.locationImageView.loadImageUsingCacheWithPlaceID(placeID: event!.location.placeID)
        self.locationImageView.loadImage(placeID: locationAttendees!.location.placeID)
        self.tableData = locationAttendees!.attendees
        
        self.tableView.reloadData()
    }
    
    func userImageTriggered(cell:AttendeeCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let cellData = self.tableData[indexPath.row]
        
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = cellData.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
            
           
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        self.navigationController?.popToRootViewController(animated: false)
    }
    
}

extension LocationAttendeesViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AttendeeCell.self), for: indexPath) as! AttendeeCell
        let cellData = self.tableData[indexPath.row]
        cell.userNameLabel.text = cellData.username
        
//        let selectedUser:User = self.tableData[indexPath.row]
//        let eventsArray = DataManager.sharedInstance.events.filter({$0.userID == selectedUser.uid}).sorted { (event1, event2) -> Bool in
//            return event1.startDate.compareByDay(date: event2.startDate) < 0
//        }
        
//        let events = DataManager.sharedInstance.events.filter({$0.uid == cellData.uid}).sorted { (event1, event2) -> Bool in
//            return event1.startDate.compareByDay(date: event2.startDate) < 0
//        }
//        
//        for index in 0...eventsArray.count - 1 {
//            let event = eventsArray[index]
////            lastEvent = eventsArray[index]
//            
//            if (currentDay.withoutTime().isBetweeen(date: event.startDate.withoutTime(), andDate: event.endDate.withoutTime()) || event.startDate.withoutTime().compareByDay(date: currentDay.withoutTime()) > 0)  {
//                if index > 0 {
//                    lastEvent = eventsArray[index - 1]
//                } else {
//                    lastEvent = eventsArray[index]
//                }
//            }
//            
//            if (currentDay.withoutTime().isBetweeenIninclusive(date: event.startDate.withoutTime(), andDate: event.endDate.withoutTime()) || currentDay.compareByDay(date: event.startDate) == 0 || currentDay.compareByDay(date: event.endDate) == 0)  {
//                if index > 0 {
//                    lastEvent = eventsArray[index - 1]
//                } else {
//                    lastEvent = eventsArray[index]
//                }               
//            }
//        }
        
        cell.userLocationLabel.text = cellData.currentLocation.uppercased()
//        cell.userLocationLabel.text = lastEvent?.location.cityName
        cell.userImageView.loadImage(url: cellData.imageURL)
        cell.imageTriggered = self.userImageTriggered
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let nextViewController =
            ScheduleViewController.storyboardInstance() {
            let selectedUser:User = self.tableData[indexPath.row]
            if selectedUser.uid != currentUser!.uid {
                nextViewController.selectedUser = selectedUser
            }
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
}
