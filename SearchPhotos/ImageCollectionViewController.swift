//
//  ImageCollectionViewController.swift
//  SearchPhotos
//
//  Created by Nanci Frank on 7/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import UIKit

private let kreuseIdentifier = "imageViewCell"

enum ImageRecordState {
    case new, downloaded, failed
}

class PendingOperations {
    lazy var downloadsInProgress = [NSIndexPath:Operation]()
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Image Download queue"
        return queue
    }()
}

class ImageRecord {
    let name: String
    let url: URL
    var state: ImageRecordState = .new
    var image: UIImage?
    
    init(name: String, url:URL) {
        self.name = name
        self.url = url
    }
}

class ImageDownloader: Operation {
    let imageRecord: ImageRecord
    
    init(imageRecord: ImageRecord) {
        self.imageRecord = imageRecord
    }
    
    override func main() {
        if self.isCancelled {
            return
        }
        
        if let imageData = try? Data(contentsOf: self.imageRecord.url) {
            guard !self.isCancelled else { return }
            if imageData.count > 0 {
                self.imageRecord.image = UIImage(data: imageData)
                self.imageRecord.state = .downloaded
            } else {
                self.imageRecord.state = .failed
                self.imageRecord.image = UIImage(named: "BrokenImage")
            }
        }
    }
}

class ImageCollectionViewController: UICollectionViewController, UISearchBarDelegate {
    
    var photoSearchController: PhotoSearchController?
    var imageData = [ImageRecord]()
    var imageCache = NSCache<AnyObject, UIImage>()
    var searchButton: UIBarButtonItem?
    var savedBackButton: UIBarButtonItem?
    var searchActive: Bool = false
    
    lazy var searchBar: UISearchBar = {
        let searchBarWidth = self.view.frame.width * 0.75
        let searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: searchBarWidth,height: 20))
        return searchBar
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = floor((UIScreen.main.bounds.size.width - 16) / 3)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        collectionView?.collectionViewLayout = layout
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchFlickr))
        searchBar.delegate = self
        
        photoSearchController!.fetchFlickrPhotosForTags("cat, cats, kitten", completion: { (result) -> Void in
            self.imageData = result
            DispatchQueue.main.async(execute: { () -> Void in
                self.collectionView?.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Search Photos
    
    func searchFlickr(_ sender: UIBarButtonItem) {
        savedBackButton = self.navigationItem.leftBarButtonItem
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(hideSearch)), animated: true)
        self.navigationItem.title = ""
        searchBar.placeholder = "Search Flickr..."
        searchActive = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            
            // Fetch the images from Flickr
            photoSearchController!.fetchFlickrPhotosForTags(searchText, completion: { (result) -> Void in
                self.imageData.removeAll()
                self.imageCache.removeAllObjects()
                self.imageData = result
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView?.reloadData()
                })
            })
        }
    }
    
    func hideSearch(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem = savedBackButton
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchFlickr))
        searchActive = false
        searchBar.resignFirstResponder()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kreuseIdentifier, for: indexPath) as? ImageCollectionViewCell
        cell?.imageStorage.layer.cornerRadius = 10.0
        
//        guard let image = imageCache.object(forKey: indexPath as AnyObject) else {
//            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
//                if let url = self.imageData[indexPath.item] as URL? {
//                    if let tempImage: Data? = try? Data(contentsOf: url), let _ = tempImage?.count, let image: UIImage? = UIImage(data: tempImage!) {
//                        DispatchQueue.main.async(execute: {
//                            cell?.imageStorage.image = image!
//                            self.imageCache.setObject(image!, forKey: indexPath as AnyObject)
//                         })
//                    } else {
//                        DispatchQueue.main.async(execute: {
//                            cell?.imageStorage.image = UIImage(named: "BrokenImage")
//                            self.imageCache.setObject(UIImage(named: "BrokenImage")!, forKey: indexPath as AnyObject)
//                        })
//                    }
//                }
//            })
//            
//            return cell!
//        }
    
        // Configure the cell
//        cell?.imageStorage.image = image as? UIImage
    
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let singleImageViewController = storyboard?.instantiateViewController(withIdentifier: "SingleImage") as? SingleImageViewController {
            singleImageViewController.imageData = [imageData[indexPath.item]]
//            singleImageViewController.imageCache = imageCache
            singleImageViewController.index = indexPath.row
            singleImageViewController.indexPath = indexPath
            
            self.navigationController?.pushViewController(singleImageViewController, animated: true)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffSet = scrollView.contentOffset.y
        let contentTrigger = scrollView.contentSize.height - scrollView.frame.size.height
        if yOffSet > contentTrigger {
            photoSearchController!.fetchFlickrPhotosForTags("cat, cats, kitten", completion: { (result) -> Void in
                self.imageData = result
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView?.reloadData()
                })
            })
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
