//
//  MainTabBarController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 19/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    static func storyboardInstance() -> MainTabBarController? {
        let storyboard = UIStoryboard(name: String(describing: MainTabBarController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        MainTabBarController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("STARTING LISTENNING ")
        DataManager.sharedInstance.startListening()
        FirebaseAPI.sharedInstance.updateCurrentUserLocation()
        
        self.selectedIndex = 1
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainTabBarController.dataChanged), name: .friendships, object: nil)
        // Do any additional setup after loading the view.
    }
    
    
    func dataChanged() {
        
        let item = self.tabBar.items?[2]
        let friendshipRequests = DataManager.sharedInstance.friendships.filter({$0.status == FriendshipStatus.pending && $0.toUserID == currentUser!.uid})
        
        
        if friendshipRequests.count > 0 {            
            item?.badgeValue = "\(friendshipRequests.count)"
            UIApplication.shared.applicationIconBadgeNumber = friendshipRequests.count
        }
        else {
            item?.badgeValue = nil            
        } 
        
    }
   

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let itemIndex = tabBar.items?.index(of: item), let navigationController = self.viewControllers?[itemIndex] as? UINavigationController {
            navigationController.popToRootViewController(animated: false)
            CalendarViewController.historyDate = nil
        }
        
        if let itemIndex = tabBar.items?.index(of: item), itemIndex == 2 {
            item.badgeValue = nil
            UIApplication.shared.applicationIconBadgeNumber = 0
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
