//
//  LikedUsersViewController.swift
//  LetSinc
//
//  Created by admin on 10/15/17.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class LikedUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var event: Event!
    var likedUsers = [User]()
    
    class func storyboardInstance(_ event: Event) -> LikedUsersViewController {
        let likedUsersVC = UIStoryboard(name: "LikedUsersViewController", bundle: nil).instantiateViewController(withIdentifier: "LikedUsersViewController") as! LikedUsersViewController
        likedUsersVC.event = event
        return likedUsersVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadDatas()
    }
    
    func loadDatas() {

        self.likedUsers = [User]()
        
        let users = DataManager.sharedInstance.users.filter({ (user) -> Bool in
            var isExist = false
            for liker in event.likes {
                if liker.byUserID == user.uid {
                    isExist = true
                }
            }
            return isExist
        }).sorted(by: { (user1, user2) -> Bool in
            return user1.username.compare(user2.username) == ComparisonResult.orderedAscending
        })
        
        self.likedUsers = users
        
        self.tableView.reloadData()
    }
    
    func userImageTriggered(cell:UITableViewCell) {
        let indexPath = self.tableView.indexPath(for: cell)!
        let cellData = self.likedUsers[indexPath.row]
        
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = cellData.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
        }
        
    }
}

extension LikedUsersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.likedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: LikedUserTableViewCell.self), for: indexPath) as! LikedUserTableViewCell
        cell.owner = tableView
        cell.indexPath = indexPath
        cell.imageTriggered = self.userImageTriggered
        let cellData = self.likedUsers[indexPath.row]
        cell.setData(cellData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let nextViewController =
            ScheduleViewController.storyboardInstance() {
            
            let cellData = self.likedUsers[indexPath.row]
            let selectedUser = userByUID(userUID: cellData.uid)
            
            nextViewController.selectedUser = selectedUser
            
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
