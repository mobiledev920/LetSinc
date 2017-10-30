//
//  LoginViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SVProgressHUD
import GooglePlaces

class LoginViewController: UIViewController {

    static func storyboardInstance() -> LoginViewController? {
        let storyboard = UIStoryboard(name: String(describing: LoginViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as? LoginViewController
    }
    
    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.signUpButton.layer.cornerRadius = self.signUpButton.frame.size.height / 2
        self.signUpButton.layer.masksToBounds = true
        
        if let loggedInUser = Auth.auth().currentUser {
            
            print("CURRENT USER EXISTS \(loggedInUser.uid)")
            // load user data and show calendar screen
            
            SVProgressHUD.show()
            
            self.signUpButton.isHidden = true
            
            FirebaseAPI.sharedInstance.getUserData(userUid: loggedInUser.uid, callback: { (user, error) in
                
                SVProgressHUD.dismiss()
                
                if let error = error {
                    self.signUpButton.isHidden = false
                    AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                    return
                }

                FirebaseAPI.sharedInstance.database.child(kUSERS).child(loggedInUser.uid).child(User.kUSERTOKEN).setValue(Messaging.messaging().fcmToken)
                
                currentUser = user
                currentUser?.deviceToken = Messaging.messaging().fcmToken ?? ""
                
                print("CURRENT USER DATA")
                print("username \(currentUser!.username)")
                print("uid \(currentUser!.uid)")
                print("imageURL \(currentUser!.imageURL.absoluteString)")
                print("phoneNumber \(currentUser!.phoneNumber)")
                print("token \(currentUser!.deviceToken)")
                
                if let nextViewController =
                    MainTabBarController.storyboardInstance() {
                    self.present(nextViewController, animated: true, completion: nil)
                }
                
            })
        }
        else {
            print("CURRENT USER DOES NOT EXIST")
        }
    }
    
    
    @IBAction func onSignUpTriggered(_ sender: UIButton) {
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if let nextViewController =
                PhoneInputViewController.storyboardInstance() {
                self.present(nextViewController, animated: true, completion: nil)
                return
            }
        }
        
        AppDelegate.getAppDelegate().requestLocationAccess(completionHandler: { (accessGranted) in
            if let nextViewController =
                PhoneInputViewController.storyboardInstance() {
                self.present(nextViewController, animated: true, completion: nil)
            }
        })
    }
    
    func showWeNeedLocation() {
        SVProgressHUD.showError(withStatus: "Access to your location is required to use the app. \n\n Please enable location access to LetSinc in your phone Settings.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
