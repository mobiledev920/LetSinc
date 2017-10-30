//
//  LocationAttendees.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 08/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
struct LocationAttendees {
    
    let location: Location
    let date:Date
    let attendees:[User]
    
}

func getLocationAttendeesFor(date:Date) -> [LocationAttendees] {
    
//    let date = date.withoutTime()
//    
//    let events = DataManager.sharedInstance.events.filter({date.withoutTime().isBetweeen(date: $0.startDate.withoutTime(), andDate: $0.endDate.withoutTime()) && ($0.userID == currentUser!.uid || isFriend(userID: $0.userID))})
    
    let date = date.withoutTime()
    let events = DataManager.sharedInstance.events.filter({date.withoutTime().isBetweeen(date: $0.startDate.withoutTime(), andDate: $0.endDate.withoutTime()) && ($0.userID == currentUser!.uid || isFriend(userID: $0.userID))})
    
  
    // separate events by location
    var eventsByPlaceID = [String:[Event]]()
    var locationsByPlaceID = [String:Location]()
    
    print("EVENTS COUNT: \(events.count)")
    
    for event in events {
        
        if eventsByPlaceID[event.location.placeID] == nil {
           eventsByPlaceID[event.location.placeID] = [Event]()
        }
        
        if locationsByPlaceID[event.location.placeID] == nil {
            locationsByPlaceID[event.location.placeID] = event.location
        }
        
        eventsByPlaceID[event.location.placeID]!.append(event)
    }
    
    var result = [LocationAttendees]()
    // for each loation events - get users
    for locationEvents in eventsByPlaceID {
        let events = locationEvents.value
        let locationAttendee = LocationAttendees(location: locationsByPlaceID[events.first!.location.placeID]!, date: date, attendees: getEventsUsers(events: events))
        
        result.append(locationAttendee)
    }
    
    var sortedResult = [LocationAttendees]()
    for la in result {
    
        if la.attendees.filter({$0.uid == currentUser!.uid}).first != nil {
            sortedResult.insert(la, at: 0)
        }
        else {sortedResult.append(la)}
    }
    
    return sortedResult
    
}
