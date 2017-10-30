//
//  PhoneVerificationViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 18/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class PhoneVerificationViewController: UIViewController {

    static func storyboardInstance() -> PhoneVerificationViewController? {
        let storyboard = UIStoryboard(name: String(describing: PhoneVerificationViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        PhoneVerificationViewController
    }
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var code1Responder: EmptyDeleteTextField!
    @IBOutlet weak var code1TF: UITextField!
    
    @IBOutlet weak var code2Responder: EmptyDeleteTextField!
    @IBOutlet weak var code2TF: UITextField!
    
    @IBOutlet weak var code3Responder: EmptyDeleteTextField!
    @IBOutlet weak var code3TF: UITextField!
    
    @IBOutlet weak var code4Responder: EmptyDeleteTextField!
    @IBOutlet weak var code4TF: UITextField!
    
    @IBOutlet weak var code5Responder: EmptyDeleteTextField!
    @IBOutlet weak var code5TF: UITextField!
    
    @IBOutlet weak var code6Responder: EmptyDeleteTextField!
    @IBOutlet weak var code6TF: UITextField!
    
    
    var currentResponder:EmptyDeleteTextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height / 2
        self.submitButton.layer.borderColor = UIColor.white.cgColor
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.masksToBounds = true
        
        self.code1Responder.deleteDelegate = self
        self.code2Responder.deleteDelegate = self
        self.code3Responder.deleteDelegate = self
        self.code4Responder.deleteDelegate = self
        self.code5Responder.deleteDelegate = self
        self.code6Responder.deleteDelegate = self
        
        self.code1Responder.delegate = self
        self.code2Responder.delegate = self
        self.code3Responder.delegate = self
        self.code4Responder.delegate = self
        self.code5Responder.delegate = self
        self.code6Responder.delegate = self
        
        
        self.code1Responder.keyboardType = .numberPad
        self.code2Responder.keyboardType = .numberPad
        self.code3Responder.keyboardType = .numberPad
        self.code4Responder.keyboardType = .numberPad
        self.code5Responder.keyboardType = .numberPad
        self.code6Responder.keyboardType = .numberPad
        
        self.code1Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        self.code2Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        self.code3Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        self.code4Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        self.code5Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        self.code6Responder.addTarget(self, action: #selector(PhoneVerificationViewController.textFieldDidChange), for: .editingChanged)
        
        
        self.code1Responder.becomeFirstResponder()
        self.currentResponder = self.code1Responder
        
        self.disableSubmitButton()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(coverKey), name: .UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func coverKey() {
        print("KEYBOARD DID HIDE")
        self.currentResponder?.becomeFirstResponder()
    }
    
    func textFieldDidChange(textField: UITextField) {
     
        
        var tf:UITextField?
        var nextResponder:UITextField?
        
        switch textField {
        case self.code1Responder:
            if textField.text != "" {
                tf = self.code1TF
                nextResponder = self.code2Responder
            } else {
                tf = nil
                nextResponder = nil
            }
        case self.code2Responder:
            tf = self.code2TF
            nextResponder = self.code3Responder
        case self.code3Responder:
            tf = self.code3TF
            nextResponder = self.code4Responder
        case self.code4Responder:
            tf = self.code4TF
            nextResponder = self.code5Responder
        case self.code5Responder:
            tf = self.code5TF
            nextResponder = self.code6Responder
        case self.code6Responder:
            if self.code6Responder.text != "" {
                tf = self.code6TF
                nextResponder = nil
            } else {
                tf = nil
                nextResponder = nil
            }
            
        default:
            break
            
        }
        
        tf?.text = "*"
        nextResponder?.text = ""
        nextResponder?.becomeFirstResponder()
        
        self.currentResponder = nextResponder as? EmptyDeleteTextField
        
        if tf == self.code6TF {
            self.enableSubmitButton()
        } else {
            self.disableSubmitButton()
        }
        
        
    }

    @IBAction func onResendCodeTriggered(_ sender: UIButton) {
        SVProgressHUD.show()
        FirebaseAPI.sharedInstance.sendPhoneVerificationCode(phoneNumber: registrationPhoneNumber!) { (success, error) in
            
            SVProgressHUD.dismiss()
            
            if let error = error {
                AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                return
            }
            
            SVProgressHUD.showSuccess(withStatus: "Resent verification code")
        }
    }
    
    @IBAction func onSubmitTriggered(_ sender: UIButton) {

        let code = "\(self.code1Responder.text!)\(self.code2Responder.text!)\(self.code3Responder.text!)\(self.code4Responder.text!)\(self.code5Responder.text!)\(self.code6Responder.text!)"
        print("CODE IS \(code)")
        
        
        SVProgressHUD.show()
        
        FirebaseAPI.sharedInstance.loginWithVerificationCode(verificationCode: code) { (success, error) in
            
            if let error = error {
                SVProgressHUD.dismiss()
                AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                return
            }
            
            // check is user already registered // todo mateo
            let userUid = Auth.auth().currentUser!.uid
            FirebaseAPI.sharedInstance.checkUserAlreadyRegistered(userUid: userUid, callback: { (user) in
                
                SVProgressHUD.dismiss()
                if let user = user
                {
                    FirebaseAPI.sharedInstance.database.child(kUSERS).child(userUid).child(User.kUSERTOKEN).setValue(Messaging.messaging().fcmToken)
                    
                    currentUser = user
                    currentUser?.deviceToken = Messaging.messaging().fcmToken ?? ""
                    
                    print("CURRENT USER DATA")
                    print("username \(currentUser!.username)")
                    print("uid \(currentUser!.uid)")
                    print("imageURL \(currentUser!.imageURL.absoluteString)")
                    print("phoneNumber \(currentUser!.phoneNumber)")
                    
                    if let nextViewController =
                        MainTabBarController.storyboardInstance() {
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                    
                }
                else {
                
                    print("user doesnt exist")
                    registrationUid = Auth.auth().currentUser!.uid
                    
                    if let nextViewController =
                        RegistrationViewController.storyboardInstance() {
                        self.present(nextViewController, animated: true, completion: nil)
                    }
                }
            })
            
            
            
            
            

            
            
        }
        
        

    }
    
    func disableSubmitButton() {
        self.submitButton.isEnabled = false
        self.submitButton.alpha = 0.3
    }
    
    func enableSubmitButton() {
        self.submitButton.isEnabled = true
        self.submitButton.alpha = 1
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

extension PhoneVerificationViewController : DeletePressedProtocol {

    func deletePressed(textField: UITextField) {
        
        var tf:UITextField?
        var nextResponder:UITextField?
        
        switch textField {
        case self.code1Responder:
            tf = self.code1TF
            nextResponder = self.code1Responder
        case self.code2Responder:
            tf = self.code1TF
            nextResponder = self.code1Responder
            self.code1Responder.text = ""
        case self.code3Responder:
            tf = self.code2TF
            nextResponder = self.code2Responder
        case self.code4Responder:
            tf = self.code3TF
            nextResponder = self.code3Responder
        case self.code5Responder:
            tf = self.code4TF
            nextResponder = self.code4Responder
        case self.code6Responder:
            if self.code6Responder.text == "" {
                tf = self.code5TF
                nextResponder = self.code5Responder
            } else {
                tf = self.code6TF
                nextResponder = self.code6Responder
            }
        default:
            break

        }
        
        tf?.text = ""
        nextResponder?.becomeFirstResponder()
        self.currentResponder = nextResponder as? EmptyDeleteTextField
    }
}

extension PhoneVerificationViewController : UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        print("RETURNING SHOULD CHANGE \(newLength <= maxLength)")
        return newLength <= maxLength
    }

}


