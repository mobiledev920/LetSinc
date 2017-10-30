//
//  SettingsViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 12/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SVProgressHUD

class SettingsViewController: UIViewController, UINavigationControllerDelegate {

    static func storyboardInstance() -> SettingsViewController? {
        let storyboard = UIStoryboard(name: String(describing: SettingsViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        SettingsViewController
    }
    
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var userImageView: LSImageView!
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var termsContainer: UIView!
    @IBOutlet weak var privacyPolicyContainer: UIView!
    @IBOutlet weak var deleteAccountContainer: UIView!
    
    let imagePicker = UIImagePickerController()
    
    var didChangeImage:Bool = false
    
    var showedImagePicker:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layoutIfNeeded()
        
//        let borderColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.25)
//        self.termsContainer.layer.addBorder(edge: .top, color: borderColor, thickness: 0.3)
//        self.privacyPolicyContainer.layer.addBorder(edge: .top, color: borderColor, thickness: 0.3)
//        self.deleteAccountContainer.layer.addBorder(edge: .top, color: borderColor, thickness: 0.3)
//        self.deleteAccountContainer.layer.addBorder(edge: .bottom, color: borderColor, thickness: 0.3)

        self.userImageView.layer.cornerRadius = self.userImageView.frame.size.height / 4
        self.saveChangesButton.layer.cornerRadius = self.saveChangesButton.frame.size.height / 2
        self.saveChangesButton.layer.borderColor = UIColor.white.cgColor
        self.saveChangesButton.layer.borderWidth = 1
        self.saveChangesButton.layer.masksToBounds = true
        self.imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
       print("OLD IMAGE URL IS \(currentUser!.imageURL.lastPathComponent)")
        if showedImagePicker {
            showedImagePicker = false
            return
        }
        
        self.didChangeImage = false
        self.usernameInput.text = currentUser!.username
        self.userImageView.loadImage(url: currentUser!.imageURL)
        self.saveChangesButton.isEnabled = false
        self.saveChangesButton.alpha = 0.5
    }
    @IBAction func onZoomImageTriggered(_ sender: UIButton) {
        if let nextViewController =
            ZoomImageViewController.storyboardInstance() {
            nextViewController.imageURL = currentUser!.imageURL
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
            
            
        }
    }

    @IBAction func onSelectImageTriggered(_ sender: UIButton) {
        
        self.showedImagePicker = true
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func onSaveChangesButtonTriggered(_ sender: UIButton) {
        
        if self.usernameInput.text == nil || self.usernameInput.text!.characters.count < 2 {
            
            SVProgressHUD.showError(withStatus: "Please input a username with 2 or more characters")
            SVProgressHUD.dismiss(withDelay: 3.0)
            return
        }

        var didShowProgress:Bool = false
        FirebaseAPI.sharedInstance.changeUserDetails(username: self.usernameInput.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), image: self.didChangeImage ? self.userImageView.image! : nil, uploadProgressCallback: { (uploadProgress) in
            didShowProgress = true
            SVProgressHUD.showProgress(uploadProgress, status: "Uploading image...")
        }) { (error) in
            
            if didShowProgress {
                SVProgressHUD.dismiss()
               
            }
            
            if let error = error {
                AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                return
            }
            print("NEW IMAGE URL IS \(currentUser!.imageURL.lastPathComponent)")
            self.userImageView.replaceLocalImage(url: currentUser!.imageURL)
            
            SVProgressHUD.showSuccess(withStatus: "Profile updated")
            SVProgressHUD.dismiss(withDelay: 2.0)
            self.didChangeImage = false
            self.handleSaveChangesButton()
        }
    }

    @IBAction func onUsernameDoneEditing(_ sender: UITextField) {
        handleSaveChangesButton()
    }
    
    
    @IBAction func onDeleteAccountTriggered(_ sender: UIButton) {
        
        let confirmAlert = UIAlertController(title: "Are you sure?", message: "Your account will be deleted. All data will be lost.", preferredStyle: UIAlertControllerStyle.alert)
        
        confirmAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            // delete user data
            // delete all user friendships 
            // delete all user events
            // logout
            FirebaseAPI.sharedInstance.deleteUserAccount()
            
            if let nextViewController =
                LoginViewController.storyboardInstance() {
                self.present(nextViewController, animated: true, completion: {
                    (UIApplication.shared.delegate as! AppDelegate).window!.rootViewController = nextViewController
                })
            }
        }))
        
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func onTermsButtonTriggered(_ sender: UIButton) {
        
        if let nextViewController =
            TermsOfServiceViewController.storyboardInstance() {
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
        }
        
        
    }
    
    @IBAction func onPrivacyPolicyButtonTriggered(_ sender: UIButton) {
        if let nextViewController =
            PrivacyPolicyViewController.storyboardInstance() {
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
        }
    }
    
    func handleSaveChangesButton() {
        if didChangeImage || (self.usernameInput.text != nil && self.usernameInput.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) != currentUser!.username) {
            self.saveChangesButton.isEnabled = true
            self.saveChangesButton.alpha = 1.0
        }
        else
        {
            self.saveChangesButton.isEnabled = false
            self.saveChangesButton.alpha = 0.5
        }
    }

}
extension SettingsViewController : UIImagePickerControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.userImageView.image = pickedImage
        }
        
        self.didChangeImage = true
        dismiss(animated: true, completion: nil)
        self.handleSaveChangesButton()
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
