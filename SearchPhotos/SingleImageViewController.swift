//
//  SingleImageViewController.swift
//  SearchPhotos
//
//  Created by Nanci Frank on 7/28/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    var imageData: [NSURL] = [NSURL]()
    var imageCache: NSCache?
    var index: Int?
    var indexPath: NSIndexPath?
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = imageCache?.objectForKey(indexPath!)
        imageView.image = image as? UIImage

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
