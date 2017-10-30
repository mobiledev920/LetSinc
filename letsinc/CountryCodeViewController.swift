//
//  CountryCodeViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 09/07/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class CountryCodeViewController: UIViewController, UISearchBarDelegate {

    static func storyboardInstance() -> UINavigationController? {
        let storyboard = UIStoryboard(name: String(describing: PhoneInputViewController.self),
                                      bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: CountryCodeViewController.self)) as?
        UINavigationController
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var countriesData = [[String:Any]]()
    var allCountriesData = [[String:Any]]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var dataSelectedAction:((String, String)->())?
    var existingRegionCode:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        if existingRegionCode == nil {
            existingRegionCode = Locale.current.regionCode
        }
        
        self.navigationController!.navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "Graphik-Regular", size: 15)!,
            NSForegroundColorAttributeName : UIColor.white
        ]
        
        do {
            if let file = Bundle.main.url(forResource: "countryCodes", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [String: Any] {
                    // json is a dictionary
                    print(object)
                } else if let object = json as? [[String:Any]] {
                    // json is an array
                    
                    self.countriesData = object
                    self.allCountriesData = object
                    
                    self.tableView.reloadData()
                    
                    var objectIndex:Int = 0
                    
                    for countryObject in self.countriesData {
                        
                        if existingRegionCode! == countryObject["code"] as? String {
                        
                            self.tableView.selectRow(at: IndexPath(row: objectIndex, section: 0), animated: true, scrollPosition: .middle)
        
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
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
        
            self.countriesData = self.allCountriesData.filter({ ($0["name"] as? String)?.lowercased().range(of: self.searchBar.text!.lowercased()) != nil })
            
        }
        else {
        
            self.countriesData = allCountriesData
        }
        
        self.tableView.reloadData()

    }
    
    
    @IBAction func onBackButtonTriggered(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
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

extension CountryCodeViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.countriesData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CountryCodeCell.self), for: indexPath) as! CountryCodeCell
        

        let cellData = self.countriesData[indexPath.row]
        let countryName = cellData["name"] as! String
        let countryCode = cellData["code"] as! String
        let phoneCode = cellData["dial_code"] as! String
        cell.countryCodeLabel.text = "\(phoneCode)"
        cell.countryNameLabel.text = "\(flag(country: countryCode)) \(countryName)"
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.08)
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("ROW SELECTED")
        let cellData = self.countriesData[indexPath.row]
        
        let phoneCode = cellData["dial_code"] as! String
        let countryCode = cellData["code"] as! String
        self.dataSelectedAction?(phoneCode, countryCode)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
