//
//  ZoomImageViewController.swift
//  LetSinc
//
//  Created by Mateo Kozomara on 09/07/2017.
//  Copyright © 2017 Mateo Kozomara. All rights reserved.
//

import UIKit

class ZoomImageViewController: UIViewController {

    static func storyboardInstance() -> ZoomImageViewController? {
        let storyboard = UIStoryboard(name: String(describing: ZoomImageViewController.self),
                                      bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: ZoomImageViewController.self)) as?
        ZoomImageViewController
    }
    
    var imageURL:URL?
    @IBOutlet weak var imageView: LSImageView!
    
    @IBAction func onDismissTriggered(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.loadImage(url: imageURL)
        // Do any additional setup after loading the view.
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
