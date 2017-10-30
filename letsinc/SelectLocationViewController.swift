//
//  SelectLocationViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 28/05/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import GooglePlaces

class SelectLocationViewController: UIViewController {
    
    static let kDefaultHeaderViewHeight: CGFloat = 30.0
    
    static func storyboardInstance() -> SelectLocationViewController? {
        let storyboard = UIStoryboard(name: String(describing: SelectLocationViewController.self),
                                      bundle: nil)
        return storyboard.instantiateInitialViewController() as?
        SelectLocationViewController
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
//    var tableData = [GMSAutocompletePrediction]()
    var tableData = [AnyObject]()
    
    var locationSelected:((Location) -> Void)?
    var placesClient: GMSPlacesClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        for view in self.searchBar.subviews {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.isEnabled = true
                }
            }
        }
        
        placesClient = GMSPlacesClient.shared()
        
        
        self.tableView.register(UINib(nibName: String(describing: SelectLocationHeaderView.self), bundle: nil), forHeaderFooterViewReuseIdentifier: String(describing: SelectLocationHeaderView.self))
        
        self.tableView.reloadData()
    }
    
    var searchTask:URLSessionTask?
    func placeAutocomplete(searchText:String) {

        
        let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedSearchText!)&types=(cities)&language=en&key=AIzaSyAgGZVAQm_UUaYIqwF2iqa8zRL-4KaAaT8")
        
        self.searchTask?.cancel()
        
        self.searchTask = URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            
            if let resultsArray = json["predictions"] as? [AnyObject] {
                self.tableData = resultsArray
            }
            else {
                self.tableData.removeAll()
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
        self.searchTask?.resume()
        
        
//        let filter = GMSAutocompleteFilter()
//        filter.type = .city
//        placesClient!.autocompleteQuery(searchText, bounds: nil, filter: filter, callback: {(results, error) -> Void in
//            if let error = error {
//                print("Autocomplete error \(error)")
//            }
//            
//            if let results = results {
//                self.tableData = results
//               }
//            else
//            {
//                self.tableData.removeAll()
//            }
//            
//            self.tableView.reloadData()
//            
//        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchBar.becomeFirstResponder()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SelectLocationViewController : UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("SEARCH TEXT: \(searchText)")
        placeAutocomplete(searchText: searchText)
    }
}

extension SelectLocationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SelectLocationCell.self), for: indexPath) as! SelectLocationCell
        let cellData = self.tableData[indexPath.row]
        
        cell.setData(data: cellData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTED")
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cellData = self.tableData[indexPath.row]
        let cityName = ((cellData["structured_formatting"] as AnyObject)["main_text"]) as? String
        let countryName = ((cellData["structured_formatting"] as AnyObject)["secondary_text"]) as? String
        let placeId = cellData["place_id"] as! String
        
//        let location = Location(cityName: cellData.attributedPrimaryText.string, countryName: cellData.attributedSecondaryText!.string, placeID: cellData.placeID!)
        let location = Location(cityName: cityName!, countryName: countryName!, placeID: placeId)
        self.locationSelected?(location)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SelectLocationViewController.kDefaultHeaderViewHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: SelectLocationHeaderView.self)) as! SelectLocationHeaderView
        
        if section == 0 {
            headerView.titleLabel.text = "SEARCH RESULTS"
        } else if section == 1{
            headerView.titleLabel.text = "ALL LOCATIONS"
        }
        return headerView
        
    }
}




