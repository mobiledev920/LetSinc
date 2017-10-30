//
//  SearchViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 28/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import TTSegmentedControl

class SearchViewController: UIViewController {

    let kFRIENDS_SECTION = "Friends"
    let kFRIENDSHIP_REQUESTS_SECTION = "Friendship requests"
    let kPENDING_FRIENDSHIPS_SECTION = "Pending friendships"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let segmentController = TTSegmentedControl()
 
    
    var friendships = [Friendship]()
    var pendingFriendships = [Friendship]()
    var friendshipRequests = [Friendship]()
    
    var tableData = [[Friendship]]()
    var sectionNames = [String]()
    
    var tableLocationData = [Location]()
    
    var selectedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        self.searchBar.layer.borderWidth = 1
        self.searchBar.layer.borderColor = UIColor(rgb: 0xFEE777).cgColor
        self.tabBarItem.badgeValue = nil
        
        // BARBUTTON: +
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus-icon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
        button.backgroundColor = UIColor(rgb: 0x40c4ea)
        button.tintColor = UIColor.white
        button.contentEdgeInsets = UIEdgeInsetsMake(3, 15, 5, 15)
        button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        button.sizeToFit()
        
        button.layer.cornerRadius = button.frame.size.height / 2
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(SearchViewController.onAddFriendTriggered), for: .touchUpInside)
        
        self.tableView.register(UINib(nibName: String(describing: ScheduleHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: ScheduleHeaderView.self))
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.dataChanged), name: .friendships, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.dataChanged), name: .users, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SearchViewController.dataChanged), name: .events, object: nil)
        
        self.dataChanged()
        self.setupNavigationBar()
    }
    
    fileprivate func setupNavigationBar() {
        self.segmentController.frame = CGRect(x: 0, y: 0, width: 150, height: 32)
        self.segmentController.allowChangeThumbWidth = false
        self.segmentController.defaultTextColor = UIColor.darkGray
        self.segmentController.thumbColor = UIColor(red: 1.0, green: 231.0/255.0, blue: 119.0/255.0, alpha: 1.0)
        self.segmentController.cornerRadius = 5.0
        self.segmentController.containerBackgroundColor = UIColor(red: 220.0/255.0, green: 200.0/255.0, blue: 107.0/255.0, alpha: 1.0)
        self.segmentController.selectedTextColor = UIColor.black
        self.segmentController.useShadow = false
        self.segmentController.useGradient = false
        self.segmentController.itemTitles = ["Friends", "Locations"]
        self.segmentController.didSelectItemWith = { (index, title) -> () in
            print("Selected item \(index)")
            self.selectedIndex = index
            if index == 0 {
                // FRIENDS
                self.searchBar.placeholder = "Search friends..."
            }
            else if index == 1 {
                // LOCATIONS
                self.searchBar.placeholder = "Search locations..."
            }
            self.tableView.reloadData()
        }
        self.navigationItem.titleView = self.segmentController
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
//        let customTabBarItem:UITabBarItem = UITabBarItem(title: "Search", image: #imageLiteral(resourceName: "schedule-tabbar-icon").withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "schedule-tabbar-icon"))
//        
//        self.navigationController?.tabBarItem = customTabBarItem
//        
//    }
    
    func dataChanged() {
        
        self.tableData = [[Friendship]]()
        self.sectionNames = [String]()
        let filteredEvents = DataManager.sharedInstance.events.filter({($0.userID == currentUser!.uid || isFriend(userID: $0.userID)) && (self.searchBar.text == "" || $0.location.cityName.lowercased().range(of: self.searchBar.text!.lowercased()) != nil || $0.location.countryName.lowercased().range(of: self.searchBar.text!.lowercased()) != nil) })
        
        self.tableLocationData = [Location]()
        
        for event in filteredEvents {
            if self.tableLocationData.filter({$0.placeID == event.location.placeID}).first == nil {
                self.tableLocationData.append(event.location)
            }
        }
        
        
        print("TABLE LOCATION DATA COUINT: \(self.tableLocationData.count)")
        
        
        self.friendships = DataManager.sharedInstance.friendships.filter({$0.status == FriendshipStatus.accepted}).filter({ (friendship) -> Bool in
            if searchBar.text == "" {
                return true
            }
            let user = userByUID(userUID: friendship.byUserID == currentUser!.uid ? friendship.toUserID : friendship.byUserID)
            return user.username.lowercased().range(of: self.searchBar.text!.lowercased()) != nil
        }).sorted(by: { (friendship1, friendship2) -> Bool in
            let user1 = userByUID(userUID: friendship1.byUserID == currentUser!.uid ? friendship1.toUserID : friendship1.byUserID)
            let user2 = userByUID(userUID: friendship2.byUserID == currentUser!.uid ? friendship2.toUserID : friendship2.byUserID)
            
            return user1.username.compare(user2.username) == ComparisonResult.orderedAscending
        })
        
        self.pendingFriendships = DataManager.sharedInstance.friendships.filter({$0.status == FriendshipStatus.pending && $0.byUserID == currentUser!.uid}).filter({ (friendship) -> Bool in
            if searchBar.text == "" {
                return true
            }
            let user = userByUID(userUID: friendship.byUserID == currentUser!.uid ? friendship.toUserID : friendship.byUserID)
            return user.username.lowercased().range(of: self.searchBar.text!.lowercased()) != nil
        }).sorted(by: { (friendship1, friendship2) -> Bool in
            let user1 = userByUID(userUID: friendship1.byUserID == currentUser!.uid ? friendship1.toUserID : friendship1.byUserID)
            let user2 = userByUID(userUID: friendship2.byUserID == currentUser!.uid ? friendship2.toUserID : friendship2.byUserID)
            
            return user1.username.compare(user2.username) == ComparisonResult.orderedAscending
        })
        
        self.friendshipRequests = DataManager.sharedInstance.friendships.filter({$0.status == FriendshipStatus.pending && $0.toUserID == currentUser!.uid}).filter({ (friendship) -> Bool in
            if searchBar.text == "" {
                return true
            }
            let user = userByUID(userUID: friendship.byUserID == currentUser!.uid ? friendship.toUserID : friendship.byUserID)
            return user.username.lowercased().range(of: self.searchBar.text!.lowercased()) != nil
        }).sorted(by: { (friendship1, friendship2) -> Bool in
            let user1 = userByUID(userUID: friendship1.byUserID == currentUser!.uid ? friendship1.toUserID : friendship1.byUserID)
            let user2 = userByUID(userUID: friendship2.byUserID == currentUser!.uid ? friendship2.toUserID : friendship2.byUserID)
            
            return user1.username.compare(user2.username) == ComparisonResult.orderedAscending
        })
        
        // section 0 = friendshipRequests
        // section 1 = pendingFriendships
        // section 2 = friendships
        
        
        
        if friendshipRequests.count > 0 {
            self.tableData.append(self.friendshipRequests)
            self.sectionNames.append(kFRIENDSHIP_REQUESTS_SECTION)
            
        }
        
        if pendingFriendships.count > 0 {
            self.tableData.append(self.pendingFriendships)
            self.sectionNames.append(kPENDING_FRIENDSHIPS_SECTION)
        }
        
        
        self.tableData.append(self.friendships)
        self.sectionNames.append(kFRIENDS_SECTION)
        
        
        self.tableView.reloadData()
    }
    
    func cellActionTriggered(actionID:String, cell:UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        if actionID == SearchFriendCell.ACCEPT_ACTION {
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.acceptFriendshipRequest(friendshipID:friendship.uid)
            FirebaseAPI.sharedInstance.getUserData(userUid: friendship.byUserID, callback: { (user, error) in
                if let error = error {
                    print("user can not find: - \(error)")
                }
                
                if let user = user {
                    FirebaseAPI.sharedInstance.sendPushNotification("\(currentUser!.username) confirmed your friend request", title: "Accept Friend", senderID: user.deviceToken)
                }
            })
        }
        else if actionID == SearchFriendCell.REJECT_ACTION {
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.rejectFriendshipRequest(friendshipID: friendship.uid)
//            FirebaseAPI.sharedInstance.getUserData(userUid: friendship.byUserID, callback: { (user, error) in
//                if let error = error {
//                    print("user can not find: - \(error)")
//                }
//
//                if let user = user {
//                    FirebaseAPI.sharedInstance.sendPushNotification("\(currentUser!.username) declined your friend request", title: "Decline Friend", senderID: user.deviceToken)
//                }
//            })
        }
        else if actionID == SearchFriendCell.DELETE_ACTION {
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.deleteFriendship(friendshipID: friendship.uid)
//            let userID = (currentUser!.uid == friendship.byUserID) ? friendship.toUserID : friendship.byUserID
//            FirebaseAPI.sharedInstance.getUserData(userUid: userID, callback: { (user, error) in
//                if let error = error {
//                    print("user can not find: - \(error)")
//                }
//
//                if let user = user {
//                    FirebaseAPI.sharedInstance.sendPushNotification("\(currentUser!.username) deleted friendship with you", title: "Deleted Friend", senderID: user.deviceToken)
//                }
//            })
        }
        else if actionID == SearchFriendCell.CANCEL_ACTION{
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.deleteFriendship(friendshipID: friendship.uid)
//            FirebaseAPI.sharedInstance.getUserData(userUid: friendship.toUserID, callback: { (user, error) in
//                if let error = error {
//                    print("user can not find: - \(error)")
//                }
//
//                if let user = user {
//                    FirebaseAPI.sharedInstance.sendPushNotification("\(currentUser!.username) cancelled friend request", title: "Cancel Friend Request", senderID: user.deviceToken)
//                }
//            })
        }
        
        let friendshipRequests = DataManager.sharedInstance.friendships.filter({$0.status == FriendshipStatus.pending && $0.toUserID == currentUser!.uid})
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        if friendshipRequests.count > 0 {
            self.tabBarItem?.badgeValue = nil
        }
        else {
            self.tabBarItem?.badgeValue = nil
        }
        
        
        
    }

    func onAddFriendTriggered(_ sender: UIButton) {
        if let nextViewController =
            AddFriendViewController.storyboardInstance() {
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    @IBAction func onSegmentedControlToggle(_ sender: UISegmentedControl) {
        if self.selectedIndex == 0 {
            // FRIENDS
            self.searchBar.placeholder = "Search friends..."
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            self.searchBar.placeholder = "Search locations..."
        }
        self.tableView.reloadData()
    }
    
    func userImageTriggered(cell:UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let cellData = self.tableData[indexPath.section][indexPath.row]
        let userID = cellData.byUserID == currentUser!.uid ? cellData.toUserID : cellData.byUserID
        let user = DataManager.sharedInstance.users.filter({$0.uid == userID}).first!
        
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = user.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
            
            
        }
        
    }
    
}

extension SearchViewController : UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataChanged()
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedIndex == 0 {
            // FRIENDS
            return self.tableData[section].count
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            return self.tableLocationData.count
        }
        
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.selectedIndex == 0 {
            // FRIENDS
            return self.tableData.count
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        if self.selectedIndex == 0 {
            // FRIENDS
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SearchFriendCell.self), for: indexPath) as! SearchFriendCell
            let cellData = self.tableData[indexPath.section][indexPath.row]
            let userID = cellData.byUserID == currentUser!.uid ? cellData.toUserID : cellData.byUserID
            let user = DataManager.sharedInstance.users.filter({$0.uid == userID}).first!
            let cell = cell as! SearchFriendCell
            let sectionName = self.sectionNames[indexPath.section]
            
            if sectionName == kFRIENDS_SECTION {
                cell.setIsFriendsSection()
            }
            else if sectionName == kFRIENDSHIP_REQUESTS_SECTION {
                cell.setIsFriendshipRequestsSection()
            }
            else if sectionName == kPENDING_FRIENDSHIPS_SECTION {
                cell.setIsPendingFriendshipsSection()
            }
            
            cell.imageTriggered = self.userImageTriggered
            
            cell.userNameLabel.text = user.username
            cell.userLocationLabel.text = user.currentLocation.uppercased()
            cell.userImageView.loadImage(url: user.imageURL)
            cell.actionTriggered = self.cellActionTriggered
            
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelectLocationCell.self), for: indexPath) as! SelectLocationCell
            let cell = cell as! SelectLocationCell
            let cellData = self.tableLocationData[indexPath.row]
            cell.cityNameLabel.text = cellData.cityName
            cell.countryNameLabel.text = cellData.countryName
            cell.locationImageView.activityIndicator.activityIndicatorViewStyle = .white
            cell.locationImageView.loadImage(placeID: cellData.placeID)
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        if self.selectedIndex == 0 {
            if let nextViewController =
                ScheduleViewController.storyboardInstance() {
                
                let cellData = self.tableData[indexPath.section][indexPath.row]
                let selectedUser = userByUID(userUID: cellData.byUserID == currentUser!.uid ? cellData.toUserID : cellData.byUserID)
                
                nextViewController.selectedUser = selectedUser
                
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
        else if self.selectedIndex == 1 {
        
            if let nextViewController =
                AllUsersInLocationViewController.storyboardInstance() {
                
                let cellData = self.tableLocationData[indexPath.row]
                nextViewController.location = cellData
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }
        
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if self.selectedIndex == 0 {
            // FRIENDS
            return ScheduleViewController.kDefaultHeaderViewHeight
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            return 0
        }
        
        return ScheduleViewController.kDefaultHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView:ScheduleHeaderView?
        if self.selectedIndex == 0 {
            // FRIENDS
            headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: ScheduleHeaderView.self)) as? ScheduleHeaderView
            let title:String = self.sectionNames[section]
            headerView!.dateLabel.text = title
            
        }
        else if self.selectedIndex == 1 {
            // LOCATIONS
            
        }
        
        return headerView
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if self.selectedIndex == 1 {
            return false
        }
        
        let sectionName = self.sectionNames[indexPath.section]
        if sectionName == kFRIENDS_SECTION {
            return true
        }
        
        return false
    }
    
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        let acceptAction = UITableViewRowAction(style: UITableViewRowActionStyle.normal, title: "Accept", handler:{action, indexpath in
            
            // accept friendship request
            
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.acceptFriendshipRequest(friendshipID:friendship.uid)
            
        })
       
        
//        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Delete", handler:{action, indexpath in
//            
//            // delete existing friend
//            self.tableView.setEditing(false, animated: true)
//            let friendship = self.tableData[indexPath.section][indexPath.row]
//            FirebaseAPI.sharedInstance.deleteFriendship(friendshipID: friendship.uid)
//            
//        })

        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "      ", handler:{action, indexpath in
          
            // delete existing friend
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.deleteFriendship(friendshipID: friendship.uid)
            
        })
        
        let img: UIImage = #imageLiteral(resourceName: "delete-action-image")
        let imgSize: CGSize = img.size
        UIGraphicsBeginImageContextWithOptions(imgSize, true, img.scale)
        img.draw(in: CGRect(x: 0, y: 0, width: self.tableView.rowHeight, height: self.tableView.rowHeight))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        deleteAction.backgroundColor = UIColor(patternImage: newImage)
        
        let rejectAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Reject", handler:{action, indexpath in
            
            // reject friendship request
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.rejectFriendshipRequest(friendshipID: friendship.uid)
            
        })
        
        let cancelAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "Cancel", handler:{action, indexpath in
            
            // cancel pending friendship request
            self.tableView.setEditing(false, animated: true)
            let friendship = self.tableData[indexPath.section][indexPath.row]
            FirebaseAPI.sharedInstance.deleteFriendship(friendshipID: friendship.uid)
            
        })
       
        var actions = [UITableViewRowAction]()
        let sectionName = self.sectionNames[indexPath.section]
        if sectionName == kFRIENDS_SECTION {
            actions.append(deleteAction)
        }
        else if sectionName == kFRIENDSHIP_REQUESTS_SECTION {
            actions.append(acceptAction)
            actions.append(rejectAction)
        }
        else if sectionName == kPENDING_FRIENDSHIPS_SECTION {
            actions.append(cancelAction)
        }
        
        return actions
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.selectedIndex == 0 {
            let cellData = self.tableData[indexPath.section][indexPath.row]
            let userID = cellData.byUserID == currentUser!.uid ? cellData.toUserID : cellData.byUserID
            if isFriend(userID: userID) {
                return indexPath
            }
            else {
                return nil
            }
        }
        else {
            return indexPath
        }

    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if self.selectedIndex == 0 {
            let cellData = self.tableData[indexPath.section][indexPath.row]
            let userID = cellData.byUserID == currentUser!.uid ? cellData.toUserID : cellData.byUserID
            if isFriend(userID: userID) {
                return true
            }
            else {
                return false
            }
        }
        else {
            return true
        }
    }
    
}
