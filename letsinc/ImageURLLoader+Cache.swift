//
//  UIImageView+Cache.swift
//  RankiTennis
//
//  Created by Mateo Kozomara on 12/09/16.
//  Copyright © 2016 Mateo Kozomara. All rights reserved.
//

import UIKit


let imageCache = NSCache<NSString,UIImage>()
let activeImageLoadingTasks = NSCache<UIImageView,URLSessionTask>()


extension UIImageView {
    
   
    func loadImageUsingCacheWithURL(url: URL?, loadComplete:(()->())?) {
        
        if let activeImageLoadingTask = activeImageLoadingTasks.object(forKey: self)
        {
            activeImageLoadingTask.cancel()
            activeImageLoadingTasks.removeObject(forKey: self)
        }
    
        
        self.image = #imageLiteral(resourceName: "user-image-blank")
        
        if let url = url{
        
            //check cache for image first
            if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString)  {
                self.image = cachedImage
                loadComplete?()
                return
            }
        
            //otherwise fire off a new download
            
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
                
            //download hit an error so lets return out
                if error != nil {
                    print(error!.localizedDescription)
                    loadComplete?()
                    return
                }
            
                DispatchQueue.main.async(execute: {
                
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: url.absoluteString as NSString)
                        self.image = downloadedImage
                        activeImageLoadingTasks.removeObject(forKey: self)
                        loadComplete?()
                    }
                })
            
            })
           
            activeImageLoadingTasks.setObject(task, forKey: self)
            task.resume()
            
        
        }
    }
    
    
    
}


