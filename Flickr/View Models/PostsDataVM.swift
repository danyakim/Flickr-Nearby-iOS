//
//  PostsDataVM.swift
//  Flickr
//
//  Created by Daniil Kim on 12.05.2021.
//

import Foundation
import UIKit

protocol PostsDataVMDelegate {
    func postsDataViewModelAddedNewPosts(count: Int, totalPages: Int)
    func postsDataViewModelFailedToGetPosts(with tag: String?)
}

class PostsDataVM {
    
    //MARK: - Properties
    
    private var posts = [Post]()
    
    private let flickrAPI = FlickrAPI()
    private let imageLoader = ImageLoader()
    
    var delegate: PostsDataVMDelegate?
    
    var previousSearch = ""
    var shouldScrollToTop = false
    
    //MARK: - Methods
    
    func count() -> Int {
        return posts.count
    }
    
    func loadPosts(near coordinates: (lat: String, lon: String)?, on page: Int = 1) {
        //if caller wants posts near location
        guard let coordinates = coordinates else {
            fatalError("Trying to load posts before getting location")
        }
        
        flickrAPI.getPhotos(location: (coordinates.lat, coordinates.lon),
                            page: page) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.updatePostsAndTotalPages(with: response!)
                }
            case .failure(let error):
                print("Failed to get photos: ", error.localizedDescription)
                DispatchQueue.main.async {
                    self.delegate?.postsDataViewModelFailedToGetPosts(with: nil)
                }
            }
            
        }
    }
    
    func loadPosts(tagged tag: String, on page: Int = 1) {
        flickrAPI.getPhotos(tag: tag, page: page) { result in
            switch result {
            case .success(let response):
                self.shouldScrollToTop = false
                if tag != self.previousSearch {
                    self.shouldScrollToTop = true
                    self.posts = []
                }
                self.previousSearch = tag
                
                DispatchQueue.main.async {
                    self.updatePostsAndTotalPages(with: response!, with: tag)
                }
                
            case .failure(let error):
                self.posts = []
                DispatchQueue.main.async {
                    self.delegate?.postsDataViewModelFailedToGetPosts(with: tag)
                }
                print("Failed to get photos: ", error.localizedDescription)
            }
        }
    }
    
    func loadImageForPost(at index: Int,
                          loadingCompletion: @escaping (UIImage?, URL) -> ()) {
        let post = posts[index]
        imageLoader.getImage(at: post.pictureURL) { image in
            loadingCompletion(image, post.highResPictureURL)
        }
    }
    
    func cancelLoadingForPost(at index: Int) {
        imageLoader.cancelLoading(for: posts[index].pictureURL)
    }
    
    func prefetchPosts(at indexes: [Int]) {
        let imagesURLs = indexes.map { posts[$0].pictureURL }
        imageLoader.startLoadingImages(at: imagesURLs)
    }
    
    func cancelPrefetchingPosts(at indexes: [Int]) {
        let imagesURLs = indexes.map { posts[$0].pictureURL}
        imageLoader.cancelLoadingImages(at: imagesURLs)
    }
    
    
    
    //MARK: - Private Methods
    
    private func updatePostsAndTotalPages(with response: (posts: [Post], totalPages: Int),
                                           with tag: String? = nil) {
        let newPosts = response.posts
        posts += newPosts
        delegate?.postsDataViewModelAddedNewPosts(count: newPosts.count,
                                     totalPages: response.totalPages)
    }
    
}
