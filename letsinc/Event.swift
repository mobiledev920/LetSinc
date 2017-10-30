//
//  Event.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 07/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
import Firebase

struct Event {
    
    static let kLOCATION = "location"
    static let kSTART_DATE = "startDate"
    static let kEND_DATE = "endDate"
    static let kUSER_ID = "userID"
    static let kLIKES = "likes"
    
    let uid: String
    let location: Location
    let startDate:Date
    let endDate:Date
    let userID:String
    var likes: [Like]
}


func parseEventDataSnapshot(snapshot:DataSnapshot) -> Event {
    let eventData = snapshot.value as! [String:AnyObject]
    print("PARSING EVENT DATA \(eventData)")
    let uid = snapshot.key
    let startDate = eventData[Event.kSTART_DATE] as! Double
    let endDate = eventData[Event.kEND_DATE] as! Double
    let userID = eventData[Event.kUSER_ID] as! String
    let locationData = eventData[Event.kLOCATION] as! [String:AnyObject]
    let locationCityName = locationData[Location.kCITY_NAME] as! String
    let locationCountryName = locationData[Location.kCOUNTRY_NAME] as! String
    let locationPlaceID = locationData[Location.kPLACE_ID] as! String

    let location = Location(cityName: locationCityName, countryName: locationCountryName, placeID: locationPlaceID)
    var likes = [Like]()
    if let likeArray = eventData[Event.kLIKES] as? [String: [String: Any]] {
        for (key, value) in likeArray {
            let likeByUserId = value[Like.kBY_USER] as! String
            let likedScheduleId = value[Like.kTO_SCHEDULE] as! String
            let status = value[Like.kSTATUS] as! Bool
            let like = Like(uid: key, byUserID: likeByUserId, toSchedule: likedScheduleId, status: status)
            likes.append(like)
        }
    }
    
    let event = Event(uid: uid, location: location, startDate: Date(timeIntervalSince1970: startDate), endDate: Date(timeIntervalSince1970: endDate), userID: userID, likes: likes)
    
    return event
}
