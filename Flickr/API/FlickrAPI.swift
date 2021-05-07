//
//  FlickrAPI.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import Foundation
import FlickrKit

class FlickrAPI {
    
    static let shared = FlickrAPI()
    
    init() {
        FlickrKit.shared().initialize(withAPIKey: K.flickrAPIKey, sharedSecret: K.flickrSecret)
    }
    
    //MARK: - Variables
    
    var cachedUsers = [String: User]()
    
    //MARK: - Methods
    
    func getPhotosNear(latitude: String, longitude: String, page: Int, completion: @escaping (Result<([Post], Int)?, Error>) -> ()) {
        
        let search = FKFlickrPhotosSearch()
        search.lat = latitude
        search.lon = longitude
        search.page = "\(page)"
        search.radius = "1"
        search.per_page = "5"
        
        FlickrKit.shared().call(search) { response, error in
            if let error = error {
                print("Failed to perform search:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let response = response {
                var result = [Post]()
                
                let photos = response["photos"] as! [String: AnyObject]
                
                let totalPages = photos["pages"]! as! Int
                
                let photoArray = photos["photo"] as! [[String: AnyObject]]
                for photo in photoArray {
                    
                    let title = "\(photo["title"]!)"
                    let ownerID = "\(photo["owner"]!)"
                    
                    let pictureID = "\(photo["id"]!)"
                    let server = "\(photo["server"]!)"
                    let secret = "\(photo["secret"]!)"
                    let farm = "\(photo["farm"]!)"
                    
                    let picture = Picture(id: pictureID, server: server, secret: secret, farm: farm)
                    
                    let post = Post(title: title, ownerID: ownerID, picture: picture)
                    
                    result.append(post)
                }
                completion(.success((result, totalPages)))
            }
        }
    }
    
    func getUserDetails(forUser user: User, completion: @escaping (Result<User,Error>) -> ()){
        if let userFound = cachedUsers[user.id] {
            completion(.success(userFound))
            return
        }
        
        let getUserInfo = FKFlickrPeopleGetInfo()
        getUserInfo.user_id = user.id
        
        FlickrKit.shared().call(getUserInfo) {[weak self] response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let response = response {
                let person = response["person"] as! [String: Any]
                let usernameDict = person["username"] as! [String: Any]
                let username = usernameDict["_content"]!
                
                let iconserver = person["iconserver"]!
                let iconfarm = person["iconfarm"]!
                let buddyimageURL = "https://farm\(iconfarm).staticflickr.com/\(iconserver)/buddyicons/\(user.id).jpg"
                
                user.name = "\(username)"
                user.photoURL = URL(string: buddyimageURL)
                
                self?.cachedUsers[user.id] = user
                
                completion(.success(user))
            }
        }
    }
    
    func getPhotosTagged(with tag: String, page: Int, completion: @escaping (Result<([Post], Int)?, Error>) -> ()){
        
        let search = FKFlickrPhotosSearch()
        search.tags = tag
        search.page = "\(page)"
        search.per_page = "5"
        
        FlickrKit.shared().call(search) { response, error in
            if let error = error {
                print("Failed to find photos with tag \"\(tag)\": ", error.localizedDescription)
                completion(.failure(error))
                return
            }
            
            if let response = response {
                var result = [Post]()
                
                let photos = response["photos"] as! [String: AnyObject]
                
                let totalPages = photos["pages"]! as! Int
                
                let photoArray = photos["photo"] as! [[String: AnyObject]]
                for photo in photoArray {
                    
                    let title = "\(photo["title"]!)"
                    let ownerID = "\(photo["owner"]!)"
                    
                    let pictureID = "\(photo["id"]!)"
                    let server = "\(photo["server"]!)"
                    let secret = "\(photo["secret"]!)"
                    let farm = "\(photo["farm"]!)"
                    
                    let picture = Picture(id: pictureID, server: server, secret: secret, farm: farm)
                    
                    let post = Post(title: title, ownerID: ownerID, picture: picture)
                    
                    result.append(post)
                }
                completion(.success((result, totalPages)))
            }
        }
    }
    
    func getHighResolutionPicture(_ picture: Picture, completion: @escaping (URL) -> ()) {
        let photoURL = FlickrKit.shared().photoURL(for: .large1024,
                                                   photoID: picture.id,
                                                   server: picture.server,
                                                   secret: picture.secret,
                                                   farm: picture.farm)
        completion(photoURL)
    }
    
    func getMediumResolutionPicture(_ picture: Picture, completion: @escaping (URL) -> ()) {
        let photoURL = FlickrKit.shared().photoURL(for: .medium640,
                                                   photoID: picture.id,
                                                   server: picture.server,
                                                   secret: picture.secret,
                                                   farm: picture.farm)
        completion(photoURL)
    }
}
