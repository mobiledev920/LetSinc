//
//  RegistrationViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 30/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class RegistrationViewController: UIViewController, UINavigationControllerDelegate {

    static func storyboardInstance() -> RegistrationViewController? {
        let storyboard = UIStoryboard(name: String(describing: RegistrationViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        RegistrationViewController
    }
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 4
        self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height / 2
        self.submitButton.layer.borderColor = UIColor.white.cgColor
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.masksToBounds = true
        imagePicker.delegate = self
    }
    
    @IBAction func onSelectImageTriggered(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func onFinishButtonTriggered(_ sender: UIButton) {
        
        if self.usernameInput.text == nil || self.usernameInput.text!.characters.count < 2 {

            SVProgressHUD.showError(withStatus: "Please input a username with 2 or more characters")
            SVProgressHUD.dismiss(withDelay: 3.0)
            return
        }

        self.usernameInput.resignFirstResponder()
        
        FirebaseAPI.sharedInstance.finishRegistration(userUid: registrationUid!, username: self.usernameInput.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), image: self.userImageView.image!, phoneNumber: registrationPhoneNumber!, uploadProgressCallback: { (uploadProgress) in
            
            SVProgressHUD.showProgress(uploadProgress, status: "Uploading image...")
            
        }) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if let error = error {
                AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                return
            }
            
            FirebaseAPI.sharedInstance.database.child(kUSERS).child(registrationUid!).child(User.kUSERTOKEN).setValue(Messaging.messaging().fcmToken)
            
            currentUser = user!
            currentUser?.deviceToken = Messaging.messaging().fcmToken ?? ""
            
            print("CURRENT USER DATA")
            print("username \(currentUser!.username)")
            print("uid \(currentUser!.uid)")
            print("imageURL \(currentUser!.imageURL.absoluteString)")
            print("phoneNumber \(currentUser!.phoneNumber)")
            print("currentLocation \(currentUser!.currentLocation)")
            
            if let nextViewController =
                MainTabBarController.storyboardInstance() {
                self.present(nextViewController, animated: true, completion: nil)
            }
        }

    }
    
}



extension RegistrationViewController : UIImagePickerControllerDelegate {
    
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.userImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
