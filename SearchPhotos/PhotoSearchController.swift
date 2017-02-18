//
//  PhotoSearchController.swift
//  SearchPhotos
//
//  Created by Nanci Frank on 7/27/16.
//  Copyright © 2016 Wildcat Productions. All rights reserved.
//

import Foundation
import UIKit

let flickrAPIKey = "a042ffdf0983cfbdebef9929db566f50"

/**** FLICKR Photo Sizes
 s	small square 75x75
 q	large square 150x150
 t	thumbnail, 100 on longest side
 m	small, 240 on longest side
 n	small, 320 on longest side
 -	medium, 500 on longest side
 z	medium 640, 640 on longest side
 c	medium 800, 800 on longest side†
 b	large, 1024 on longest side*
 h	large 1600, 1600 on longest side†
 k	large 2048, 2048 on longest side†
 o	original image, either a jpg, gif or png, depending on source format
 */
enum PhotoSizes: String {
    case Original = "o"
    case Large2048 = "k"
    case Large1600 = "h"
    case Large1024 = "b"
    case Medium800 = "c"
    case Medium640 = "z"
    case Medium500 = "-"
    case Small320 = "n"
    case Small240 = "m"
    case Thumbnail100 = "t"
    case LargeSquare = "q"
    case SmallSquare = "s"
}

enum FlickrAPIMethod: String {
    case photoSearch = "flickr.photos.search"
}

protocol FlickrPhoto {
    var photoDict: NSDictionary {get set}
    func urlForPhotoWithSize(_ photoSize: PhotoSizes) -> URL
}

struct Photo: FlickrPhoto {
    var photoDict: NSDictionary
    
    func urlForPhotoWithSize(_ photoSize: PhotoSizes) -> URL {
        let farm = photoDict["farm"]
        let secret = photoDict["secret"]
        let serverId = photoDict["server"]
        let photoId = photoDict["id"]
        let photoSize = photoSize.rawValue
        
        return URL(string: "https://farm\(farm!).staticflickr.com/\(serverId!)/\(photoId!)_\(secret!)_\(photoSize).jpg")!
    }
}

struct FlickrURL {
    let baseURL = "https://api.flickr.com/services/rest/?format=json&nojsoncallback=1&safe_search=1&content_type1&"
    var method: FlickrAPIMethod
    var perPage: Int
    
    func withParams(_ params: [String: String]) -> URL {
        let apiString = Parameters(parameters: ["method": "\(method.rawValue)", "per_page": "\(perPage)"]).parameterStringEncoded()
        let paramString = Parameters(parameters: params).parameterStringEncoded()
        return URL(string: baseURL + apiString + "&" + paramString)!
    }
}

struct FlickrAPI {
    var method: Method
    
    enum Method: String {
        case photoSearch = "flickr.photos.search"
    }
}

struct Parameters {
    var parameters = [String: String]()
    
    func parameterStringEncoded() -> String
    {
        return parameters.map({ "\($0)=\($1)" }).joined(separator: "&").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
    }
}

class PhotoSearchController {
    
    func fetchFlickrPhotosForTags(_ tags: String, completion: @escaping (_ result: [ImageRecord]) -> Void) {
        
        let requestURL = FlickrURL(method: FlickrAPIMethod.photoSearch, perPage: 50).withParams(["api_key": "\(flickrAPIKey)", "tags": "\(tags)"])
        let session = URLSession.shared
        let task = session.dataTask(with: requestURL, completionHandler: {data, response, error -> Void in
            var photoArray = [ImageRecord]()
            do {
                let jsonOptions: JSONSerialization.ReadingOptions = [.allowFragments, .mutableLeaves, .mutableContainers]
                let result = try JSONSerialization.jsonObject(with: data!, options: jsonOptions) as! [String: AnyObject]
                if let photosDictionary = result["photos"] as? NSDictionary, let photos = photosDictionary["photo"] as? [NSDictionary] {
                    for photo in photos {
                        let photoUrl: URL = Photo(photoDict: photo).urlForPhotoWithSize(PhotoSizes.Large1024)
                        let title = photo["title"] as? NSString ?? ""
                        let imageRecord = ImageRecord(name: title as String, url: photoUrl)
                        photoArray.append(imageRecord)
                    }
                    completion(photoArray)
                }
            }
            catch let jsonParseError {
                print("error occurred \(jsonParseError)")
            }
        })
        
        task.resume()
    }
}
