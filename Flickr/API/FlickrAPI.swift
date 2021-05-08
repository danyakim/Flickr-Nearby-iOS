//
//  FlickrAPI.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import Foundation
import FlickrKit

enum FlickrAPIError: Error {
    case noResults
}

class FlickrAPI {
    
    static let shared = FlickrAPI()
    
    init() {
        FlickrKit.shared().initialize(withAPIKey: K.API.flickrAPIKey, sharedSecret: K.API.flickrSecret)
    }
    
    //MARK: - Variables
    
    var cachedUsers = [String: User]()
    
    //MARK: - Methods
    
    func getPhotos(location: (String, String)? = nil, tag: String? = nil, page: Int, completion: @escaping (Result<([Post], Int)?, Error>) -> ()) {
        
        let search = FKFlickrPhotosSearch()
        
        if let location = location {
            search.lat = location.0
            search.lon = location.1
            search.radius = "1"
        } else {
            search.tags = tag!
        }
        
        search.page = "\(page)"
        search.per_page = "\(K.API.per_page)"
        
        search.sort = "interestingness-desc"
        search.extras = "owner_name, url_m, url_l, url_t, url_s, url_n, url_z, url_c"
        
        FlickrKit.shared().call(search) { response, error in
            if let error = error {
                print("Failed to perform search:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let response = response {
                if let posts = self.parse(response) {
                    completion(.success(posts))
                } else {
                    print("Search didn't give results")
                    completion(.failure(FlickrAPIError.noResults))
                }
            }
        }
    }
    
    //MARK: - Helping Functions
    
    func parse(_ response: [String: Any]) -> ([Post], Int)? {
        var result = [Post]()
        
        let photos = response["photos"] as! [String: AnyObject]
        let totalPages = photos["pages"]! as! Int
        
        let photoArray = photos["photo"] as! [[String: AnyObject]]
        
        if photoArray.count == 0 { return nil }
        
        for photo in photoArray {
            //get post data
            let title = "\(photo["title"]!)"
            if photo["url_m"] == nil {
                print("no middle res picture")
            }
            
            let availableResolution = photo["url_m"] ?? photo["url_n"] ?? photo["url_s"] ?? photo["url_t"]!
            let highestAvailableResolution = photo["url_l"] ?? photo["url_c"] ?? photo["url_z"] ?? availableResolution
            
            let pictureURL = URL(string: "\(availableResolution)")!
            
            let highResURL = URL(string: "\(highestAvailableResolution)")!
            
            let post = Post(title: title, pictureURL: pictureURL, highResURL: highResURL)
            
            //get user data
            let username = "\(photo["ownername"]!)"
            
            let ownerID = "\(photo["owner"]!)"
            let iconserver = "\(photo["server"]!)"
            let iconfarm = "\(photo["farm"]!)"
            let buddyimageURL = "https://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(ownerID).jpg"
            
            post.user = User(name: username, photoURL: URL(string: buddyimageURL)!)
            
            result.append(post)
        }
        
        return (result, totalPages)
    }
    
}
