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
    lazy var downloadsInProgress = [IndexPath:Operation]()
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

class ImageCollectionViewController: UICollectionViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var photoSearchController: PhotoSearchController?
    var imageDataSource: [ImageRecord] = [ImageRecord]()
    var searchButton: UIBarButtonItem?
    var savedBackButton: UIBarButtonItem?
    var searchActive: Bool = false
    var searchTags: String = "cat, cats, kitten"
    let searchController = UISearchController(searchResultsController: nil)
    
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout: UICollectionViewFlowLayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let itemSize = floor((UIScreen.main.bounds.size.width - 16) / 3)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        collectionView?.collectionViewLayout = layout
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        definesPresentationContext = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchFlickr))
        
        photoSearchController!.fetchFlickrPhotosForTags(searchTags, completion: { (result) -> Void in
            self.imageDataSource = result
            OperationQueue.main.addOperation {
                self.collectionView?.reloadData()
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.addSubview(searchController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startDownloadForImageRecord(_ imageDetails: ImageRecord, indexPath: IndexPath) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let downloader = ImageDownloader(imageRecord: imageDetails)
        
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            OperationQueue.main.addOperation {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
        pendingOperations.downloadsInProgress[indexPath] = downloader
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    // MARK: Search Photos
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        self.collectionView?.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        searchController.isActive = true
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
//        searchController.isActive = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchFlickr))
    }
    
    func searchFlickr(_ sender: UIBarButtonItem) {
        print("searchFlickr")
        view.addSubview(searchController.view)
        searchController.searchBar.placeholder = "Search Flickr..."
        searchController.isActive = true
    }
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if let searchText = searchBar.text {
//            
//            // Fetch the images from Flickr
//            photoSearchController!.fetchFlickrPhotosForTags(searchText, completion: { (result) -> Void in
//                self.searchTags = searchText
//                self.imageDataSource.removeAll()
//                self.imageDataSource = result
//                OperationQueue.main.addOperation {
//                    self.collectionView?.reloadData()
//                }
//            })
//        }
//    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageDataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kreuseIdentifier, for: indexPath) as? ImageCollectionViewCell
        cell?.imageStorage.layer.cornerRadius = 10.0
        cell?.indicator.startAnimating()
        
        let imageDetails = imageDataSource[indexPath.row]
        cell?.imageStorage.image = imageDetails.image
        
        switch imageDetails.state {
        case .failed:
            cell?.indicator.stopAnimating()
            break
        case .new:
            self.startDownloadForImageRecord(imageDetails, indexPath: indexPath)
        case .downloaded:
            cell?.indicator.stopAnimating()
        }
    
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let storyboard: UIStoryboard? = UIStoryboard(name: "Main", bundle: nil), let singleImageViewController = storyboard?.instantiateViewController(withIdentifier: "SingleImage") as? SingleImageViewController {
            singleImageViewController.imageData = [imageDataSource[indexPath.item]]
            singleImageViewController.index = indexPath.row
            singleImageViewController.indexPath = indexPath
            
            self.navigationController?.pushViewController(singleImageViewController, animated: true)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffSet = scrollView.contentOffset.y
        let contentTrigger = scrollView.contentSize.height - scrollView.frame.size.height
        if yOffSet > contentTrigger {
            photoSearchController!.fetchFlickrPhotosForTags(searchTags, completion: { (result) -> Void in
                self.imageDataSource = result
                OperationQueue.main.addOperation {
                    self.collectionView?.reloadData()
                }
            })
        }
    }

}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageStorage: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        indicator.stopAnimating()
        imageStorage.image = nil
    }
}
