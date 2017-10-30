//
//  Like.swift
//  letsinc
//
//  Created by admin on 10/14/17.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import Firebase

struct Like {
    
    static let kBY_USER = "byUserID"
    static let kTO_SCHEDULE = "toSchedule"
    static let kSTATUS = "status"
    
    let uid:String
    let byUserID: String
    let toSchedule:String
    let status:Bool
    
}

func parseLikeDataSnapshot(snapshot:DataSnapshot) -> Like? {
    let likeData = snapshot.value as! [String:AnyObject]
    print("PARSING LIKE DATA \(likeData)")
    let uid = snapshot.key
    
    guard let byUserT = likeData[Like.kBY_USER], let toScheduleT = likeData[Like.kTO_SCHEDULE], let statusT = likeData[Like.kSTATUS] else {
        return nil
    }
    let byUser = byUserT as! String
    let toSchedule = toScheduleT as! String
    let status = statusT as! Bool
    
    let like = Like(uid: uid, byUserID: byUser, toSchedule: toSchedule, status: status)
    return like
}
