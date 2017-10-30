//
//  AddFriendViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 28/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SVProgressHUD

class AddFriendViewController: UIViewController {

    static func storyboardInstance() -> AddFriendViewController? {
        let storyboard = UIStoryboard(name: String(describing: AddFriendViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        AddFriendViewController
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var tableData = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Graphik-Regular", size: 17)!,
            NSForegroundColorAttributeName : UIColor(rgb:0x4A4D52)
        ]
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        

        self.searchBar.layer.borderWidth = 1
        self.searchBar.layer.borderColor = UIColor(rgb: 0xFEE777).cgColor
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(AddFriendViewController.dataChanged), name: .friendships, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchBar.becomeFirstResponder()
    }
    
    func dataChanged() {
        self.searchBar(self.searchBar, textDidChange: self.searchBar.text != nil ? self.searchBar.text! : "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}

extension AddFriendViewController : UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // filter users but dont include friends
        self.tableData = getNotFriendUsers().filter({$0.username.lowercased().contains(searchText.lowercased())})
        self.tableView.reloadData()
    }
}

extension AddFriendViewController : UITableViewDelegate, UITableViewDataSource {
    
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
        cell.userLocationLabel.text = cellData.currentLocation.uppercased()
        cell.userImageView.loadImage(url: cellData.imageURL)
        cell.imageTriggered = self.userImageTriggered
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTED")
        
        let user = self.tableData[indexPath.row]
        
        let confirmAlert = UIAlertController(title: "Add Friend?", message: "Send friendship request to \(user.username)", preferredStyle: UIAlertControllerStyle.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action: UIAlertAction!) in
            self.tableView.deselectRow(at: indexPath, animated: true)
            FirebaseAPI.sharedInstance.createFriendshipRequest(user: user)
            
            FirebaseAPI.sharedInstance.sendPushNotification("\(currentUser!.username) wants to be friend with you", title: "Friend Request", senderID: user.deviceToken)
            SVProgressHUD.showSuccess(withStatus: "Sent friend request to \(user.username)")
            SVProgressHUD.dismiss(withDelay: 2.0)
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
            self.tableView.deselectRow(at: indexPath, animated: true)
        }))
        
        present(confirmAlert, animated: true, completion: nil)
        
        
       
        
        
    }
    
}
