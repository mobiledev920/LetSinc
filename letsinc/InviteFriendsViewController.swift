//
//  InviteFriendsViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import Contacts

class InviteFriendsViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTopConstraint: NSLayoutConstraint!
    static fileprivate let kTableViewCellReuseIdentifier = "InviteFriendsCell"
    
    @IBOutlet weak var tableView: UITableView!
    var tableData = [CNContact]()
    var allContacts = [CNContact]()
    
    static func storyboardInstance() -> UINavigationController? {
        let storyboard = UIStoryboard(name: String(describing: InviteFriendsViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        UINavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let font = UIFont(name: "Graphik-Regular", size: 15) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font]
        }
        self.searchBar.delegate = self
        self.searchBarTopConstraint.constant = -self.searchBar.frame.size.height
        
    }
    
    @IBAction func onSearchButtonTriggered(_ sender: UIBarButtonItem) {
        self.showSearchBar()
    }
    @IBAction func onDoneButtonTriggered(_ sender: UIBarButtonItem) {
        // continue to next ViewController
        if let nextViewController =
            MainTabBarController.storyboardInstance() {
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    
    func showSearchBar() {
        self.searchBarTopConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        self.searchBar.becomeFirstResponder()
    }
    
    func hideSearchBar() {
        self.searchBar.resignFirstResponder()
        self.searchBarTopConstraint.constant = -self.searchBar.frame.size.height
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestAccess()
    }
    
    func requestAccess() {
        AppDelegate.getAppDelegate().requestContactsAccess { (accessGranted) in
            
            if accessGranted {
                let contactStore = AppDelegate.getAppDelegate().contactStore
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
                let request = CNContactFetchRequest(keysToFetch: keys)
                
                do {
                    try contactStore.enumerateContacts(with: request) {
                        (contact, stop) in
                        // Array containing all unified contacts from everywhere
                        self.tableData.append(contact)
                        self.allContacts.append(contact)
                        
                    }
                    
                    self.tableView.reloadData()
                }
                catch {
                    print("unable to fetch contacts")
                }
            }
            else {
                let when = DispatchTime.now() + 0.5 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when) {
                    // Your code with delay
                    AppDelegate.getAppDelegate().showMessage(title: "Oops", message: "To invite friends please allow contact access in Settings", completionHandler: {
                        
                    })
                }
                
                
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InviteFriendsViewController : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InviteFriendsViewController.kTableViewCellReuseIdentifier, for: indexPath) as! InviteFriendsCell
        let contact = self.tableData[indexPath.row]
        cell.userNameLabel.text = "\(contact.givenName) \(contact.familyName)"
        return cell
    }
    
    
}

extension InviteFriendsViewController : UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchBar(searchBar, textDidChange: "")
        self.hideSearchBar()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SEACH TEXT_ \(searchText)")
        
        self.tableData = self.allContacts.filter({ (contact) -> Bool in
            if searchText == "" || contact.givenName.lowercased().range(of:searchText.lowercased()) != nil ||
                contact.familyName.lowercased().range(of:searchText.lowercased()) != nil
                {
                return true
            }
            else {
                return false
            }
        })
        self.tableView.reloadData()
    }
    
    
}
