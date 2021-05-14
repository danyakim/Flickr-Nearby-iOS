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
    case noResponse
    case noTag
}

class FlickrAPI {
    
    //MARK: - Properties
    
    var uniquePosts = Set<URL>()
    
    //MARK: - Methods
    
    init() {
        FlickrKit.shared().initialize(withAPIKey: K.API.flickrAPIKey, sharedSecret: K.API.flickrSecret)
    }
    
    func getPhotos(location: (String, String)? = nil,
                   tag: String? = nil,
                   page: Int,
                   completion: @escaping (Result<(posts: [Post],totalPages: Int)?, Error>) -> ()) {
        
        let search = FKFlickrPhotosSearch()
        
        if let location = location {
            search.lat = location.0
            search.lon = location.1
            search.radius = "1"
        } else {
            guard let tag = tag else {
                completion(.failure(FlickrAPIError.noTag))
                return
            }
            
            search.tags = tag
        }
        
        search.page = "\(page)"
        search.per_page = "\(K.API.per_page)"
        search.extras = "url_m, url_l, url_t, url_s, url_n, url_z, url_c, url_q, url_sq"
        
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
            } else {
                completion(.failure(FlickrAPIError.noResponse))
            }
        }
    }
    
    //MARK: - Helping Functions
    
    func parse(_ response: [String: Any]) -> (posts: [Post], totalPages: Int)? {
        var result = [Post]()
        
        guard let photos = response["photos"] as? [String: Any],
              let totalPages = photos["pages"] as? Int,
              let photoArray = photos["photo"] as? [[String: Any]],
              photoArray.count != 0 else { return nil }
        
        for photo in photoArray {
            guard let availableResolution = photo["url_n"] ??
                photo["url_s"] ??
                photo["url_q"] ??
                photo["url_sq"] ??
                photo["url_t"] else { continue }
            let highestAvailableResolution = photo["url_l"] ??
                photo["url_c"] ??
                photo["url_z"] ??
                photo["url_m"] ??
                availableResolution
            guard let pictureURL = URL(string: availableResolution as? String ?? ""),
                  let highResURL = URL(string: highestAvailableResolution as? String ?? "") else { continue }
            
            if uniquePosts.insert(pictureURL).inserted == false { continue }
            
            let post = Post(pictureURL: pictureURL, highResURL: highResURL)
            result.append(post)
        }
        return (result, totalPages)
    }
    
}
