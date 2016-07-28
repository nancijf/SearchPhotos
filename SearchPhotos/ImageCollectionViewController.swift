//
//  ImageCollectionViewController.swift
//  SearchPhotos
//
//  Created by Nanci Frank on 7/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

private let kreuseIdentifier = "imageViewCell"

class ImageCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    var photoSearchController: PhotoSearchController?
    var imageData: [NSURL] = [NSURL]()
    var imageCache: NSCache = NSCache()
    var searchButton: UIBarButtonItem?
    var savedBackButton: UIBarButtonItem?
    var searchActive: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let searchBarWidth = self.view.frame.width * 0.75
        let searchBar = UISearchBar(frame: CGRectMake(0,0,searchBarWidth,20))
        return searchBar
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = floor((UIScreen.mainScreen().bounds.size.width - 16) / 3)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        collectionView?.collectionViewLayout = layout
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(searchFlickr))
        searchBar.delegate = self
        
        photoSearchController!.fetchFlickrPhotosForTags("cat, cats, kitten", completion: { (result) -> Void in
            self.imageData = result
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.collectionView?.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Search Photos
    
    func searchFlickr(sender: UIBarButtonItem) {
        savedBackButton = self.navigationItem.leftBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(hideSearch)), animated: true)
        self.navigationItem.title = ""
        searchBar.placeholder = "Search Flickr..."
        searchActive = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            
            // Fetch the images from Flickr
            photoSearchController!.fetchFlickrPhotosForTags(searchText, completion: { (result) -> Void in
                self.imageData.removeAll()
                self.imageCache.removeAllObjects()
                self.imageData = result
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.collectionView?.reloadData()
                })
            })
        }
    }
    
    func hideSearch(sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = savedBackButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Search, target: self, action: #selector(searchFlickr))
        searchActive = false
        searchBar.resignFirstResponder()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageData.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kreuseIdentifier, forIndexPath: indexPath) as? ImageCollectionViewCell
        cell?.imageStorage.layer.cornerRadius = 10.0
        
        guard let image = imageCache.objectForKey(indexPath) else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                if let url = self.imageData[indexPath.item] as NSURL? {
                    if let tempImage: NSData? = NSData(contentsOfURL: url), let _ = tempImage?.length, let image: UIImage? = UIImage(data: tempImage!) {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell?.imageStorage.image = image!
                            self.imageCache.setObject(image!, forKey: indexPath)
                         })
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            cell?.imageStorage.image = UIImage(named: "BrokenImage")
                            self.imageCache.setObject(UIImage(named: "BrokenImage")!, forKey: indexPath)
                        })
                    }
                }
            })
            
            return cell!
        }
    
        // Configure the cell
        cell?.imageStorage.image = image as? UIImage
    
        return cell!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selected image: \(indexPath)")
        if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let singleImageViewController = storyboard?.instantiateViewControllerWithIdentifier("SingleImage") as? SingleImageViewController {
            singleImageViewController.imageData = imageData
            singleImageViewController.imageCache = imageCache
            singleImageViewController.index = indexPath.row
            singleImageViewController.indexPath = indexPath
            
            self.navigationController?.pushViewController(singleImageViewController, animated: true)
        }
    }

}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageStorage: UIImageView!
    
    override func prepareForReuse() {
        let nothing: UIImage? = nil
        imageStorage.image = nothing
    }
}
