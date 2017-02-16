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
        
//        if image!.size.width > image!.size.height {
//            if image!.size.width > view.frame.size.width {
//                scaledImage = scaleImage(image!, maxSize: view.frame.size.width)
//            }
//        } else {
//            if image!.size.height > view.frame.size.height {
//                scaledImage = scaleImage(image!, maxSize: view.frame.size.height)
//            }
//        }

        imageView.image = image

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
//    func scaleImage(photo: UIImage, maxSize: CGFloat) -> UIImage {
//        
//        let maxEdge = max(photo.size.height, photo.size.width)
//        let scale = maxSize/maxEdge
//        let scaledSize = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
//        let rect = CGRect(origin: CGPointZero, size: scaledSize)
//        
//        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
//        photo.drawInRect(rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }

}
