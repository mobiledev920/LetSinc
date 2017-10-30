//
//  FirebaseAPI.swift
//  UpWatch
//
//  Created by Mateo Kozomara on 26/10/16.
//  Copyright © 2016 Mateo Kozomara. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth
import GooglePlaces
import SVProgressHUD
import Alamofire

// GOOGLE PLACES API AIzaSyAgGZVAQm_UUaYIqwF2iqa8zRL-4KaAaT8
let kAuthVerificationID = "authVerificationID"

//MARK: database collections
let kUSERS = "users"
let kEVENTS = "events"
let kFRIENDSHIPS = "friendships"
let kLIKESCHEDULE = "likes"

//MARK: storage
let kUSER_IMAGES = "user_images"

enum DataAction:String {
    case added = "added"
    case changed = "changed"
    case removed = "removed"
}

class FirebaseAPI : NSObject, CLLocationManagerDelegate{
    
    //MARK: Shared Instance
    var database:DatabaseReference
    var storage:StorageReference
    
    static let sharedInstance : FirebaseAPI = {
        let instance = FirebaseAPI()
        return instance
    }()
    
    private override init() {
        
        Database.database().isPersistenceEnabled = true
        
        self.database = Database.database().reference()
        self.storage = Storage.storage().reference()
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageSuccess(_:)), name: NSNotification.Name.MessagingSendSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendDataMessageFailure(_:)), name: NSNotification.Name.MessagingSendError, object: nil)
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                print("Connected !!!!!!!!!!!!!")
            } else {
                print("Not connected  !!!!!!!!!!!!!")
            }
        })
    }
    
    public func sendPhoneVerificationCode(phoneNumber:String, callback: @escaping (Bool, String?) -> ()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                callback(false, error.localizedDescription)
                print(error)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: kAuthVerificationID)
            callback(true, nil)
        }
    }
    
    public func loginWithVerificationCode(verificationCode:String, callback: @escaping (Bool, String?) -> ()) {
        
        if let verificationID = UserDefaults.standard.string(forKey: kAuthVerificationID) {
        
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode)
            
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    callback(false, error.localizedDescription)
                    return
                }
                
                // User is signed in
                callback(true, nil)
            }
        }
        else
        {
            callback(false, "Something went terribly wrong")
        }
    }
    
    public func finishRegistration(userUid:String, username:String, image:UIImage, phoneNumber:String, uploadProgressCallback:@escaping (Float) -> (), finishedCallback: @escaping (User?, String?) -> ()) {
        
        var adjustedImage = image
        let imageRef = storage.child("\(kUSER_IMAGES)/\(userUid).jpg")
        if image.size.width > 500
        {
            adjustedImage = image.resized(toWidth: 500)!
        }
        if image.size.height > 500
        {
            adjustedImage = image.resized(toHeight: 500)!
        }
        
        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageData = UIImageJPEGRepresentation(adjustedImage, 1.0)! as Data
        
        // Upload file and metadata to the object 'images/mountains.jpg'
        let uploadTask = imageRef.putData(imageData, metadata: metadata)
        imageRef.putData(imageData, metadata: metadata) { (resultMetadata, error) in
            uploadTask.removeAllObservers()
            if let error = error
            {
                finishedCallback(nil, error.localizedDescription)
                return
            }
            
            self.getUserLocation(callback: { (cityName) in
                
                let userData = [
                    User.kUSERNAME:username,
                    User.kIMAGE_URL:resultMetadata!.downloadURL()!.absoluteString,
                    User.kPHONE_NUMBER:phoneNumber,
                    User.kCURRENT_LOCATION:cityName == nil ? "unknown" : cityName!,
                    User.kUSERTOKEN: Messaging.messaging().fcmToken
                ]
                
                self.database.child(kUSERS).child(userUid).setValue(userData)
                
                let user = User(uid: userUid, username: username, imageURL: resultMetadata!.downloadURL()!, phoneNumber: phoneNumber, currentLocation:cityName == nil ? "unknown" : cityName!, deviceToken: Messaging.messaging().fcmToken ?? "")
                
                finishedCallback(user, nil)
                
            })
            
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            
            print("UPLOAD PERCENT COMPLETE: \(percentComplete)")
            uploadProgressCallback(Float(percentComplete))
        }
        
        
    }
    
    public func changeUserDetails(username:String, image:UIImage?, uploadProgressCallback:@escaping (Float) -> (), finishedCallback: @escaping (String?) -> ()) {
        if let image = image {
            var adjustedImage = image
            let imageRef = storage.child("\(kUSER_IMAGES)/\(currentUser!.uid).jpg")
            if image.size.width > 500
            {
                adjustedImage = image.resized(toWidth: 500)!
            }
            if image.size.height > 500
            {
                adjustedImage = image.resized(toHeight: 500)!
            }
            
            // Create the file metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageData = UIImageJPEGRepresentation(adjustedImage, 1.0)! as Data
            
            // Upload file and metadata to the object 'images/mountains.jpg'
            let uploadTask = imageRef.putData(imageData, metadata: metadata)
            imageRef.putData(imageData, metadata: metadata) { (resultMetadata, error) in
                uploadTask.removeAllObservers()
                if let error = error
                {
                    finishedCallback(error.localizedDescription)
                    return
                }
                
                self.database.child(kUSERS).child(currentUser!.uid).child(User.kIMAGE_URL).setValue(resultMetadata!.downloadURL()!.absoluteString)
                self.database.child(kUSERS).child(currentUser!.uid).child(User.kUSERNAME).setValue(username)
                
                currentUser!.imageURL = resultMetadata!.downloadURL()!
                currentUser!.username = username
                let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Your code with delay
                    finishedCallback(nil)
                }
            }
            
            uploadTask.observe(.progress) { snapshot in
                // Upload reported progress
                
                if let progress = snapshot.progress {
                    let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    print("UPLOAD PERCENT COMPLETE: \(percentComplete)")
                    uploadProgressCallback(Float(percentComplete))
                }
            }
        }
        else {
            self.database.child(kUSERS).child(currentUser!.uid).child(User.kUSERNAME).setValue(username)
            currentUser!.username = username
            let when = DispatchTime.now() + 0.25 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                // Your code with delay
                finishedCallback(nil)
            }
            
        }
        
    }
    
    public func getUserData(userUid:String, callback: @escaping (User?, String?) -> ()) {
        
        var taskDidExecute = false
        let task = DispatchWorkItem {
            taskDidExecute = true
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.database.child(kUSERS).child(userUid).removeValue()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            callback(nil, "LetSinc: Error occured while trying to login")
        }
        
        // 10 second timeout
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: task)
        
        
        print("GETTING USER DATA: \(userUid)")
        database.child(kUSERS).child(userUid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            task.cancel()
            
            print("GOT USER DATA ")
            if let userData = snapshot.value as? [String:AnyObject] {
                if let userName = userData[User.kUSERNAME] as? String, let imageUrlString = userData[User.kIMAGE_URL] as? String {
                    let user = User(uid: snapshot.key, username: userName, imageURL: URL(string: imageUrlString)!, phoneNumber: userData[User.kPHONE_NUMBER] as! String, currentLocation: userData[User.kCURRENT_LOCATION] as! String, deviceToken: userData[User.kUSERTOKEN] as? String ?? "")
                    callback(user, nil)
                } else {
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        self.database.child(kUSERS).child(userUid).removeValue()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                    
                    callback(nil, "LetSinc: Error occured while trying to auto-login")
                }
            }
            else if !taskDidExecute
            {
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                    self.database.child(kUSERS).child(userUid).removeValue()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                callback(nil, "LetSinc: Error occured while trying to auto-login")
            }
            
        })
        
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    public func checkUserAlreadyRegistered(userUid:String, callback: @escaping (User?) -> ()) {
        
        print("CHECKING USER REGISTERED: \(userUid)")
        
        database.child(kUSERS).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("GOT USER DATA ")
            if snapshot.hasChild(userUid){
                
                print("true user exist")
                
                let userData = snapshot.childSnapshot(forPath: userUid).value as! [String:AnyObject]
                
                if let userName = userData[User.kUSERNAME] as? String, let imageUrlString = userData[User.kIMAGE_URL] as? String, let phoneNumber = userData[User.kPHONE_NUMBER] as? String {
                    let user = User(uid: snapshot.key, username: userName, imageURL: URL(string: imageUrlString)!, phoneNumber: phoneNumber, currentLocation: userData[User.kCURRENT_LOCATION] as! String, deviceToken: userData[User.kUSERTOKEN] as? String ?? "")
                    callback(user)
                } else {
                    let firebaseAuth = Auth.auth()
                    do {
                        try firebaseAuth.signOut()
                        self.database.child(kUSERS).child(userUid).removeValue()
                    } catch let signOutError as NSError {
                        print ("Error signing out: %@", signOutError)
                    }
                    
                    callback(nil)
                }
            } else {
                callback(nil)
            }
            
        })
        
    }
    
    func updateCurrentUserLocation() {
        
//        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
//        
//            SVProgressHUD.showError(withStatus: "Access to your location is required to use the app. \n\n Please enable location access to LetSinc in your phone Settings.")
//            return
//        }
        
        
        self.updateLocation()
        
    }
    let manager = CLLocationManager()
    
    func updateLocation() {
        manager.delegate = self
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.manager.stopUpdatingLocation()
        if let location = locations.first {
            print("Found user's location: \(location)")
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                
                if  error != nil {
                   return
                } else {
                    
                    let placeArray = placemarks
                    
                    var placeMark: CLPlacemark!
                    
                    placeMark = placeArray?[0]
                    
                 
                    if let user = currentUser, let city = placeMark.addressDictionary?["City"] {
                        
                        self.database.child(kUSERS).child(user.uid).child(User.kCURRENT_LOCATION).setValue(city)
                    }
                    
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
//    private func updateUserLocation() {
//        
//        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) -> Void in
//            if let error = error {
//                print("Pick Place error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let placeLikelihoodList = placeLikelihoodList {
//                
//                print("LIKELIHOODS:::::")
//                print(placeLikelihoodList.likelihoods)
//                
//                if let likelihood = placeLikelihoodList.likelihoods.first {
//                    let place = likelihood.place
//                    
//                    let cityComponent = place.addressComponents!.filter({$0.type == "locality"}).first!
//                    if let user = currentUser {
//                        
//                        self.database.child(kUSERS).child(user.uid).child(User.kCURRENT_LOCATION).setValue(cityComponent.name)
//                    }
//                    
//                    
//                    
//                }
//            }
//        })
//    }
    
    func getUserLocation(callback:@escaping (String?) -> ()) {
        if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            callback(nil)
            return
        }
        GMSPlacesClient.shared().currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                callback(nil)
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                if let likelihood = placeLikelihoodList.likelihoods.first {
                    let place = likelihood.place
                    
                    if let addresses = place.addressComponents, let cityComponent = addresses.filter({$0.type == "locality"}).first {
                    
                        callback(cityComponent.name)
                    }
                    else {
                        callback(nil)
                    }
                    
                } else {
                    callback(nil)
                }
            } else {
                callback(nil)
            }
            
        })
    }
    
    func createEvent(location:Location, startDate:Date, endDate:Date) {

        let newEvent = database.child(kEVENTS).childByAutoId()
        print("StartDate Time From 1970 Fire \(startDate.timeIntervalSince1970)")
        
        let eventData = [
            Event.kLOCATION: [
                Location.kPLACE_ID:location.placeID,
                Location.kCITY_NAME:location.cityName,
                Location.kCOUNTRY_NAME:location.countryName
            ],
            Event.kSTART_DATE:Double(startDate.timeIntervalSince1970),
            Event.kEND_DATE:Double(endDate.timeIntervalSince1970),
            Event.kUSER_ID: currentUser!.uid
        ] as [String : Any]
        
        newEvent.setValue(eventData)
    }
    
    func editEvent(eventID:String, location:Location, startDate:Date, endDate:Date, likes: [Like], byUser: String) {
        
        let existingEvent = database.child(kEVENTS).child(eventID)
        var eventData = [
            Event.kLOCATION: [
                Location.kPLACE_ID:location.placeID,
                Location.kCITY_NAME:location.cityName,
                Location.kCOUNTRY_NAME:location.countryName
            ],
            Event.kSTART_DATE:Double(startDate.timeIntervalSince1970),
            Event.kEND_DATE:Double(endDate.timeIntervalSince1970),
            Event.kUSER_ID: byUser
            ] as [String : Any]
        
        var likeData = [String: Any]()
        for like in likes {
            let likeInfo = [
                Like.kBY_USER: like.byUserID,
                Like.kTO_SCHEDULE: like.toSchedule,
                Like.kSTATUS: like.status
                ] as [String : Any]
            
            likeData[like.uid] = likeInfo
        }
        
        eventData[Event.kLIKES] = likeData
        
        existingEvent.setValue(eventData)
    }
    
    func deleteEvent(eventID:String) {
        database.child(kEVENTS).child(eventID).removeValue()
    }

    func createFriendshipRequest(user:User) {
        
        let newFriendship = database.child(kFRIENDSHIPS).childByAutoId()
        let eventData = [
            Friendship.kBY_USER : currentUser!.uid,
            Friendship.kTO_USER : user.uid,
            Friendship.kSTATUS : FriendshipStatus.pending.rawValue
            ] as [String : Any]
        
        newFriendship.setValue(eventData)
    }
    
    func acceptFriendshipRequest(friendshipID:String) {
        database.child(kFRIENDSHIPS).child(friendshipID).child(Friendship.kSTATUS).setValue(FriendshipStatus.accepted.rawValue)
    }
    
    func rejectFriendshipRequest(friendshipID:String) {
        database.child(kFRIENDSHIPS).child(friendshipID).child(Friendship.kSTATUS).setValue(FriendshipStatus.rejected.rawValue)
    }
    
    func deleteFriendship(friendshipID:String) {
        database.child(kFRIENDSHIPS).child(friendshipID).removeValue()
    }
    
    func deleteUserAccount() {
        
        // delete user events
        for event in DataManager.sharedInstance.events {
            if event.userID == currentUser!.uid {
                database.child(kEVENTS).child(event.uid).removeValue()
            }
            
            for like in event.likes {
                var copyEvent = event
                if like.byUserID == currentUser!.uid {
                    let index = event.likes.index(where: { (item) -> Bool in
                        return item.uid == like.uid
                    })
                    
                    if let index = index {
                        copyEvent.likes.remove(at: index)
                        self.editEvent(eventID: copyEvent.uid, location: copyEvent.location, startDate: copyEvent.startDate, endDate: copyEvent.endDate, likes: copyEvent.likes, byUser: copyEvent.userID)
                    }
                }
            }
        }
        // delete user friendships
        for friendship in DataManager.sharedInstance.friendships {
            database.child(kFRIENDSHIPS).child(friendship.uid).removeValue()
        }
        // delete user
        database.child(kUSERS).child(currentUser!.uid).removeValue()
        
        // logout
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    //MARK: listeners
    public func listenToEventsCollection(callback:@escaping (Event, DataAction) -> ()) {
    
        database.child(kEVENTS).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            let event = parseEventDataSnapshot(snapshot: snapshot)
            callback(event, .added)
            
        })
        
        database.child(kEVENTS).queryOrderedByKey().observe(.childChanged, with: { (snapshot) in
            
            let event = parseEventDataSnapshot(snapshot: snapshot)
            callback(event, .changed)
            
        })
        
        database.child(kEVENTS).queryOrderedByKey().observe(.childRemoved, with: { (snapshot) in
            
            let event = parseEventDataSnapshot(snapshot: snapshot)
            callback(event, .removed)
            
        })
        
    }
    
    public func listenToUsersCollection(callback:@escaping (User?, DataAction) -> ()) {
        
        database.child(kUSERS).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            let user = parseUserDataSnapshot(snapshot: snapshot)
            callback(user, .added)
            
        })
        
        database.child(kUSERS).queryOrderedByKey().observe(.childChanged, with: { (snapshot) in
            
            let user = parseUserDataSnapshot(snapshot: snapshot)
            callback(user, .changed)
            
        })
        
        database.child(kUSERS).queryOrderedByKey().observe(.childRemoved, with: { (snapshot) in
            
            let user = parseUserDataSnapshot(snapshot: snapshot)
            callback(user, .removed)
            
        })
        
    }
    
    public func listenToFriendshipsCollection(callback:@escaping (Friendship, DataAction) -> ()) {
        
        database.child(kFRIENDSHIPS).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            guard let friendship = parseFriendshipDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(friendship, .added)
            
        })
        
        database.child(kFRIENDSHIPS).queryOrderedByKey().observe(.childChanged, with: { (snapshot) in
            
            guard let friendship = parseFriendshipDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(friendship, .changed)
            
        })
        
        database.child(kFRIENDSHIPS).queryOrderedByKey().observe(.childRemoved, with: { (snapshot) in
            
            guard let friendship = parseFriendshipDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(friendship, .removed)
            
        })
        
    }
    
    public func listenToLikeScheduleCollection(callback:@escaping (Like, DataAction) -> ()) {
        
        database.child(kLIKESCHEDULE).queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            
            guard let like = parseLikeDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(like, .added)
            
        })
        
        database.child(kLIKESCHEDULE).queryOrderedByKey().observe(.childChanged, with: { (snapshot) in
            
            guard let like = parseLikeDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(like, .changed)
            
        })
        
        database.child(kLIKESCHEDULE).queryOrderedByKey().observe(.childRemoved, with: { (snapshot) in
            
            guard let like = parseLikeDataSnapshot(snapshot: snapshot) else {
                return
            }
            callback(like, .removed)
            
        })
        
    }
    
    public func sendPushNotification(_ message: String, title: String, senderID: String) {
        var messages = ["to": senderID, "priority" : "high"] as [String : Any]
        let notification = ["body": message, "title": title, "sound": "default", "badge": "1"]
        messages["notification"] = notification
        
        let header = [
            "Content-Type": "application/json",
            "Authorization": "key=AIzaSyAYmkODa6cIcXsKvAHlQfiV6oR5D0HpUBw"
        ]
        
        Alamofire.request("https://fcm.googleapis.com/fcm/send", method: .post, parameters: messages, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
            switch response.result {
            case .success(let data):
                print(data)
                break
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func sendDataMessageFailure(_ notification: Notification) {
        let usserInfo = notification.userInfo
        print(usserInfo ?? [:])
    }
    
    func sendDataMessageSuccess(_ notification: Notification) {
        let usserInfo = notification.userInfo
        print(usserInfo ?? [:])
    }
    
}

extension FirebaseAPI: AuthUIDelegate {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        print(viewControllerToPresent)
        if let viewController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            viewController.pushViewController(viewControllerToPresent, animated: flag)
        }
    }
    
    func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        print(flag)
    }
}
