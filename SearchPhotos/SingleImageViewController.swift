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
    var index: Int?
    var indexPath: IndexPath?
    var imageToDisplay: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = imageToDisplay {
            imageView.image = image
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
