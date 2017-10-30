//
//  DataManager.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 07/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let events = Notification.Name(kEVENTS)
    static let users = Notification.Name(kUSERS)
    static let friendships = Notification.Name(kFRIENDSHIPS)
    static let like = Notification.Name(kLIKESCHEDULE)
}

class DataManager {
    
    
    //MARK: Shared Instance
    static let sharedInstance : DataManager = {
        let instance = DataManager()
        return instance
    }()
    

    public var events = [Event]()
    public var users = [User]()
    public var friendships = [Friendship]()
    public var likes = [Like]()
    
    func startListening() {
        
        events = [Event]()
        users = [User]()
        
        FirebaseAPI.sharedInstance.listenToEventsCollection { (event, dataAction) in
            
            let existingEvent = self.events.filter({$0.uid == event.uid}).first
            
            switch dataAction {
            case .added:
                // new data
                if existingEvent == nil
                {
                    self.events.append(event)
                    print("Added event: \(event.uid)")
                }
                break
            case .removed:
                // deleted data
                if existingEvent != nil
                {
                    let index:Int = self.events.index(where: {$0.uid == event.uid})!
                    self.events.remove(at: index)
                    print("Deleted event: \(event.uid)")
                }
                break
            case .changed:
                // edited data
                if existingEvent != nil
                {
                    let index:Int = self.events.index(where: {$0.uid == event.uid})!
                    self.events[index] = event
                    print("Changed event (existing): \(event.uid)")
                }
                else
                {
                    self.events.append(event)
                    print("Changed event (unexisting): \(event.uid)")
                }
                break
                
            }
            
            NotificationCenter.default.post(name: .events, object: nil)
            
        }
        
        FirebaseAPI.sharedInstance.listenToUsersCollection { (user, dataAction) in
            guard let user = user else {
                return
            }
            
            let existingUser = self.users.filter({$0.uid == user.uid}).first
            
            switch dataAction {
            case .added:
                // new data
                if existingUser == nil
                {
                    self.users.append(user)
                    print("Added user: \(user.uid)")
                }
                break
            case .removed:
                // deleted data
                if existingUser != nil
                {
                    let index:Int = self.users.index(where: {$0.uid == user.uid})!
                    self.users.remove(at: index)
                    print("Deleted user: \(user.uid)")
                }
                break
            case .changed:
                // edited data
                if existingUser != nil
                {
                    let index:Int = self.users.index(where: {$0.uid == user.uid})!
                    self.users[index] = user
                    print("Changed user (existing): \(user.uid)")
                }
                else
                {
                    self.users.append(user)
                    print("Changed user (unexisting): \(user.uid)")
                }
                break
                
            }
            
            NotificationCenter.default.post(name: .users, object: nil)
            
        }
        
        FirebaseAPI.sharedInstance.listenToFriendshipsCollection { (friendship, dataAction) in
            
            if friendship.byUserID != currentUser!.uid && friendship.toUserID != currentUser!.uid {
                // not my friendship so ignore
                return
            }
            
            let existingFriendship = self.friendships.filter({$0.uid == friendship.uid}).first
            
            switch dataAction {
            case .added:
                // new data
                if existingFriendship == nil
                {
                    self.friendships.append(friendship)
                    print("Added friendship: \(friendship.uid)")
                }
                break
            case .removed:
                // deleted data
                if existingFriendship != nil
                {
                    let index:Int = self.friendships.index(where: {$0.uid == friendship.uid})!
                    self.friendships.remove(at: index)
                    print("Deleted friendship: \(friendship.uid)")
                }
                break
            case .changed:
                // edited data
                if existingFriendship != nil
                {
                    let index:Int = self.friendships.index(where: {$0.uid == friendship.uid})!
                    self.friendships[index] = friendship
                    print("Changed friendship (existing): \(friendship.uid)")
                }
                else
                {
                    self.friendships.append(friendship)
                    print("Changed friendship (unexisting): \(friendship.uid)")
                }
                break
                
            }
            
            NotificationCenter.default.post(name: .friendships, object: nil)
            
        }
        
        
//        FirebaseAPI.sharedInstance.listenToLikeScheduleCollection { (like, dataAction) in
//            
//            if like.byUserID != currentUser!.uid && like.toSchedule != currentUser!.uid {
//                // not my friendship so ignore
//                return
//            }
//            
//            let existingLike = self.likes.filter({$0.uid == like.uid}).first
//            
//            switch dataAction {
//            case .added:
//                // new data
//                if existingLike == nil
//                {
//                    self.likes.append(like)
//                    print("Added like: \(like.uid)")
//                }
//                break
//            case .removed:
//                // deleted data
//                if existingLike != nil
//                {
//                    let index:Int = self.friendships.index(where: {$0.uid == like.uid})!
//                    self.likes.remove(at: index)
//                    print("Deleted friendship: \(like.uid)")
//                }
//                break
//            case .changed:
//                // edited data
//                if existingLike != nil
//                {
//                    let index:Int = self.likes.index(where: {$0.uid == like.uid})!
//                    self.likes[index] = like
//                    print("Changed friendship (existing): \(like.uid)")
//                }
//                else
//                {
//                    self.likes.append(like)
//                    print("Changed friendship (unexisting): \(like.uid)")
//                }
//                break
//                
//            }
//            
//            NotificationCenter.default.post(name: .like, object: nil)
//            
//        }
        
    }
    
    
    
}
