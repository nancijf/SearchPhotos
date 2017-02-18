//
//  SingleImageViewController.swift
//  SearchPhotos
//
//  Created by Nanci Frank on 7/28/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

class SingleImageViewController: UIViewController {
    
    var imageData = [ImageRecord]()
    var imageCache = NSCache<AnyObject, UIImage>()
    var index: Int?
    var indexPath: IndexPath?
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = imageCache.object(forKey: indexPath! as AnyObject)! as UIImage
        
        imageView.image = image

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
