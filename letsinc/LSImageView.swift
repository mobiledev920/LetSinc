//
//  LSImageView.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 08/06/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit
import GooglePlaces

class LSImageView: UIImageView {

    
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    func setActivityIndicatorColor(rgb:UInt) {
        self.activityIndicator.color = UIColor(rgb:rgb)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initActivityIndicator()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.initActivityIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initActivityIndicator()
    }
    
    func initActivityIndicator() {
        self.addSubview(activityIndicator)
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: self.activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

    }
    
    func loadImage(url:URL?) {
        
        self.activityIndicator.startAnimating()
        self.loadImageUsingCacheWithURL(url: url) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                if let img = self.image, let u = url {
                    let _ = self.saveImage(image: img, named: u.lastPathComponent)
                    print("saving local image \(u.lastPathComponent)")
                }
                
                if self.image == nil {
                    if let u = url, let i = self.getSavedImage(named: u.lastPathComponent) {
                        self.image = i
                    }
                }
            }
        }
    }
    
    func replaceLocalImage(url:URL) {
       let _ = self.saveImage(image: self.image!, named: url.lastPathComponent)
    }
    
    private var currentPlaceID:String?
    
    func loadImage(placeID:String?)  {
        
        self.activityIndicator.startAnimating()
        self.currentPlaceID = placeID
        loadImageUsingCacheWithPlaceID(placeID: placeID)
    }
    
    private func loadImageUsingCacheWithPlaceID(placeID:String?)  {
        
        self.image = nil
        
        if let placeID = placeID {
            
            if let cachedImage = imageCache.object(forKey: placeID as NSString)  {
                
                self.image = cachedImage
                self.activityIndicator.stopAnimating()
                return
            }
            
            
            GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
                if let error = error {
                    // TODO: handle the error.
                    self.activityIndicator.stopAnimating()
                    print("Error loading image from placeID: \(error.localizedDescription)")
                    if let i = self.getSavedImage(named: "\(placeID).jpg") {
                        self.image = i
                        print("loading local image")
                        
                    }
                } else {
                    if let firstPhoto = photos?.results.first {
                        self.loadImageForMetadata(photoMetadata: firstPhoto, placeID: placeID)
                    }
                }
            }
            
        }
    }
    
    private func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, placeID:String) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            self.activityIndicator.stopAnimating()
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
                if let i = self.getSavedImage(named: "\(placeID).jpg") {
                    self.image = i
                    print("loading local image")
                }
            } else {
                if self.currentPlaceID == placeID {
                    imageCache.setObject(photo!, forKey: self.currentPlaceID! as NSString)
                    self.image = photo
                    let _ = self.saveImage(image: photo!, named: "\(placeID).jpg")
                    print("saving local image \(placeID)")
                }
                else {
                    print("PLACE ID CHANGED")
                }
                
                
            }
        })
    }
    
    private func saveImage(image: UIImage, named:String) -> Bool {
        guard let data = UIImageJPEGRepresentation(image, 1) ?? UIImagePNGRepresentation(image) else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent(named)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    private func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }

}
