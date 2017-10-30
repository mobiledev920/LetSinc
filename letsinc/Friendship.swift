//
//  Friendship.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 08/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation
import Firebase

enum FriendshipStatus:String {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    
    static func fromRaw(value:String) -> FriendshipStatus {
        switch value {
        case "pending":
            return FriendshipStatus.pending
        case "accepted":
            return FriendshipStatus.accepted
        case "rejected":
            return FriendshipStatus.rejected
        default:
            return FriendshipStatus.pending
        }
    }
    
}

struct Friendship {
    
    static let kBY_USER = "byUserID"
    static let kTO_USER = "toUserID"
    static let kSTATUS = "status"
    
    let uid:String
    let byUserID: String
    let toUserID:String
    let status:FriendshipStatus
    
}

func parseFriendshipDataSnapshot(snapshot:DataSnapshot) -> Friendship? {
    let friendshipData = snapshot.value as! [String:AnyObject]
    print("PARSING FRIENDSHIP DATA \(friendshipData)")
    let uid = snapshot.key
    
    guard let byUserT = friendshipData[Friendship.kBY_USER], let toUserT = friendshipData[Friendship.kTO_USER], let statusT = friendshipData[Friendship.kSTATUS] else {
        return nil
    }
    let byUser = byUserT as! String
    let toUser = toUserT as! String
    let status = statusT as! String
    
    let friendship = Friendship(uid: uid, byUserID: byUser, toUserID: toUser, status: FriendshipStatus.fromRaw(value: status))
    return friendship
}

func getNotFriendUsers() -> [User] {
    
    var result = [User]()
    
    for user in DataManager.sharedInstance.users {
        
        if user.uid != currentUser!.uid && DataManager.sharedInstance.friendships.filter({($0.status == FriendshipStatus.accepted || $0.status == FriendshipStatus.pending) && ($0.byUserID == user.uid || $0.toUserID == user.uid)}).count == 0 {
            result.append(user)
        }
        
    }
    return result
}

func isFriend(userID:String) -> Bool {
    return DataManager.sharedInstance.friendships.filter({ $0.status == FriendshipStatus.accepted && ($0.byUserID == userID || $0.toUserID == userID) }).first != nil
}
