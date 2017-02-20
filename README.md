# SearchPhotos
This iPhone app takes advantage of the Flickr API to search their public photos. The returned photos are displayed in a grid using a UICollectionView. Once the photos are loaded in the grid, you can click on any photo to see the full image in a single view.

### Latest revisions are:
  - Updated to Swift 3.0
  - Now uses OperationQueue instead of GCD
  - Implemented UISearchController 
  - Implemented continuous scrolling of images
  
## Frameworks and APIs:
  - [Flickr API](https://www.flickr.com/services/developer/api/) to access the photos
  - [Alamofire 4.3](https://github.com/Alamofire/Alamofire) to get JSON data


