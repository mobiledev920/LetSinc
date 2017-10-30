//
//  User.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 05/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
import Firebase

struct User {
    static let kUSERNAME = "username"
    static let kIMAGE_URL = "imageURL"
    static let kPHONE_NUMBER = "phoneNumber"
    static let kCURRENT_LOCATION = "currentLocation"
    static let kUSERTOKEN = "deviceToken"
    
    var uid:String
    var username: String
    var imageURL:URL
    var phoneNumber:String
    var currentLocation:String
    var deviceToken: String
}

var currentUser:User? // TODO MATEO TESTING https://i.diawi.com/Rk4Xs4 
//var currentUser:User? = User(uid: "U9hHOzaR3pTxjx4K1uNU1pwkQRX2", username: "Mateo", imageURL: URL(string:"https://firebasestorage.googleapis.com/v0/b/letsinc-689bf.appspot.com/o/user_images%2FU9hHOzaR3pTxjx4K1uNU1pwkQRX2.jpg?alt=media&token=fe160616-6e1a-41d9-a417-90c317c34567")!, phoneNumber: "+385919888071", currentLocation: "Zagreb")


func parseUserDataSnapshot(snapshot:DataSnapshot) -> User? {
    let userData = snapshot.value as! [String:AnyObject]
    print("PARSING USER DATA \(userData)")
    let uid = snapshot.key
    
    if let userName = userData[User.kUSERNAME] as? String, let imageUrlString = userData[User.kIMAGE_URL] as? String {
        let user = User(uid: snapshot.key, username: userName, imageURL: URL(string: imageUrlString)!, phoneNumber: userData[User.kPHONE_NUMBER] as! String, currentLocation: userData[User.kCURRENT_LOCATION] as! String, deviceToken: userData[User.kUSERTOKEN] as? String ?? "")
        return user
    } else {
        FirebaseAPI.sharedInstance.database.child(kUSERS).child(uid).removeValue()
    }
    return nil
}

//func userIDsToUsers(userIDs:[String]) -> [User] {
//
//    var result = [User]()
//    for userID in userIDs {
//        if let user = DataManager.sharedInstance.users.filter({$0.uid == userID}).first {
//            result.append(user)
//        }
//        
//    }
//    return result
//}

//func getEventUsers(event:Event, date:Date) -> [User] {
//
//    let events = DataManager.sharedInstance.events.filter({$0.location.placeID == event.location.placeID && date.isBetweeen(date: $0.startDate, andDate: $0.endDate)})
//    
//    var result = [User]()
//    let userIDs = events.map({$0.userID})
//    let uniqueUserIDs = [String](Set(userIDs))
//    
//    for userID in uniqueUserIDs {
//        if let user = DataManager.sharedInstance.users.filter({$0.uid == userID}).first {
//            result.append(user)
//        }
//    }
//    
//    return result
//    
//}

func userByUID(userUID:String) -> User {
    return DataManager.sharedInstance.users.filter({$0.uid == userUID}).first!
}

func getEventsUsers(events:[Event]) -> [User] {
     
    var result = [User]()
    let userIDs = events.map({$0.userID})
    let uniqueUserIDs = [String](Set(userIDs))
    
    for userID in uniqueUserIDs {
        if let user = DataManager.sharedInstance.users.filter({$0.uid == userID}).first {
            result.append(user)
        }
    }
    
    return result
}
