//
//  PhoneInputViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 30/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import SVProgressHUD
import PhoneNumberKit
import ActiveLabel

class PhoneInputViewController: UIViewController {

    static func storyboardInstance() -> PhoneInputViewController? {
        let storyboard = UIStoryboard(name: String(describing: PhoneInputViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        PhoneInputViewController
    }
    
    @IBOutlet weak var termsPrivacyLabel: ActiveLabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var phoneInput: PhoneNumberTextField!
    
    @IBOutlet weak var phoneCodeLabel: PhoneNumberTextField!
    
    let phoneNumberKit = PhoneNumberKit()
    
    var allCountriesData = [[String:Any]]()
    var currentRegionCode = Locale.current.regionCode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let privacyType = ActiveType.custom(pattern: "\\sPrivacy Policy\\b")
        let termsType = ActiveType.custom(pattern: "\\sTerms of Service\\b")
        
        termsPrivacyLabel.enabledTypes = [privacyType, termsType]
        termsPrivacyLabel.text = "By clicking submit you agree to our\nPrivacy Policy and Terms of Service"
        
        termsPrivacyLabel.customColor[privacyType] = UIColor(rgb: 0xFEEC92)
        termsPrivacyLabel.customSelectedColor[privacyType] = UIColor(rgb: 0xFEEC92)
        termsPrivacyLabel.customColor[termsType] = UIColor(rgb: 0xFEEC92)
        termsPrivacyLabel.customSelectedColor[termsType] = UIColor(rgb: 0xFEEC92)
        
        termsPrivacyLabel.handleCustomTap(for: privacyType) { element in
            if let nextViewController =
                PrivacyPolicyViewController.storyboardInstance() {
                nextViewController.modalPresentationStyle = .overCurrentContext
                self.present(nextViewController, animated: true, completion: nil)
            }
        }
        termsPrivacyLabel.handleCustomTap(for: termsType) { element in
            if let nextViewController =
                TermsOfServiceViewController.storyboardInstance() {
                nextViewController.modalPresentationStyle = .overCurrentContext
                self.present(nextViewController, animated: true, completion: nil)
            }
        }
        
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [[String:Any]] {
                    // json is an array
                    
                    
                    self.allCountriesData = object
                    
                    var objectIndex:Int = 0
                    
                    for countryObject in self.allCountriesData {
                        
                        if currentRegionCode == countryObject["code"] as? String {
                            
                            let phoneCode = countryObject["dial_code"] as! String
                            self.phoneCodeLabel.text = phoneCode
                            
                            break
                        }
                        objectIndex = objectIndex + 1
                    }
                    
                } else {
                    print("JSON is invalid")
                }
            } else {
                print("no file")
            }
        } catch {
            print(error.localizedDescription)
        }
        
        // Do any additional setup after loading the view.
        
        self.submitButton.layer.cornerRadius = self.submitButton.frame.size.height / 2
        self.submitButton.layer.borderColor = UIColor.white.cgColor
        self.submitButton.layer.borderWidth = 1
        self.submitButton.layer.masksToBounds = true
    }

    @IBAction func onPhoneInputChanged(_ sender: PhoneNumberTextField) {
    
//        if let text = self.phoneInput.text {
//            if text.characters.count == 1 && text != "+"
//            {
//                self.phoneInput.text = "+\(text)"
//            }
//        }
//        
    }
    @IBAction func onCodeInputTriggered(_ sender: UIButton) {
        if let nextViewController =
            CountryCodeViewController.storyboardInstance() {
            let countryCodeViewController = nextViewController.viewControllers.first! as! CountryCodeViewController
            countryCodeViewController.dataSelectedAction = self.onPhoneCodeSelected
            countryCodeViewController.existingRegionCode = currentRegionCode
            nextViewController.modalPresentationStyle = .overCurrentContext
            self.present(nextViewController, animated: true, completion: nil)
        }
        
        
    }
    
    func onPhoneCodeSelected(phoneCode:String, regionCode:String) {
        print("selected phone code: \(phoneCode)")
        self.phoneCodeLabel.text = phoneCode
        self.currentRegionCode = regionCode
    }
    
    @IBAction func onSubmitButtonTriggered(_ sender: UIButton) {

        var pn = self.phoneInput.text!.replacingOccurrences(of: " ", with: "")
        pn = pn.replacingOccurrences(of: "-", with: "")
        pn = pn.replacingOccurrences(of: "(", with: "")
        pn = pn.replacingOccurrences(of: ")", with: "")
        
        let phoneNumberText = "\(self.phoneCodeLabel.text!)\(pn)"
        do {
            let phoneNumber = try phoneNumberKit.parse(phoneNumberText)
            print("PH: \(phoneNumber.numberString)")
        }
        catch {
            print("Generic parser error")
            SVProgressHUD.showError(withStatus: "Please input a valid phone number")
            SVProgressHUD.dismiss(withDelay: 2.0)
            return
        }
        
        SVProgressHUD.show()
        
        registrationPhoneNumber = phoneNumberText
        FirebaseAPI.sharedInstance.sendPhoneVerificationCode(phoneNumber: registrationPhoneNumber!) { (success, error) in
            
            SVProgressHUD.dismiss()
            
            if let error = error {
                AppDelegate.getAppDelegate().showMessage(title: "Oops", message: error, completionHandler: nil)
                return
            }

            if let nextViewController =
                PhoneVerificationViewController.storyboardInstance() {
                self.present(nextViewController, animated: true, completion: nil)
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
