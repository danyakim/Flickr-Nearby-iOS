//
//  PostsDataViewModel.swift
//  Flickr
//
//  Created by Daniil Kim on 12.05.2021.
//

import Foundation

protocol PostsDataViewModelDelegate {
    func postsDataViewModel(didAddNewPostsAt indexPaths: [IndexPath], totalPages: Int)
    func postsDataViewModelFailedToGetPosts(with tag: String?)
}

class PostsDataViewModel {
    
    //MARK: - Properties
    
    private var postViewModels = [PostViewModel]()
    private let flickrAPI = FlickrAPI()
    
    var delegate: PostsDataViewModelDelegate?
    
    var previousSearch = ""
    var shouldScrollToTop = false
    
    //MARK: - Image Loading Operations
    
    private var loadingQueue = OperationQueue()
    private var loadingOperations: [IndexPath: LoadPictureOperation] = [:]
    
    func removeLoadingOperation(for indexPath: IndexPath) {
        loadingOperations.removeValue(forKey: indexPath)
    }
    
    //MARK: - Methods
    
    func count() -> Int {
        return postViewModels.count
    }
    
    func loadImageForPost(at indexPath: IndexPath,
                          loadingCompletion: @escaping (PostViewModel) -> ()) {
        if let pictureLoader = loadingOperations[indexPath] {
            
            if let loadedPicture = pictureLoader.loadedPicture {
                var postViewModel = postViewModels[indexPath.row]
                postViewModel.loadedPicture = loadedPicture
                loadingCompletion(postViewModel)
            } else {
                pictureLoader.loadingCompletionHandler = loadingCompletion
            }
            
        } else {
            
            if let pictureLoader = postViewModels[indexPath.row].loadPicture() {
                pictureLoader.loadingCompletionHandler = loadingCompletion
                loadingQueue.addOperation(pictureLoader)
                loadingOperations[indexPath] = pictureLoader
            } else {
                loadingCompletion(postViewModels[indexPath.row])
            }
            
        }
    }
    
    func cancelLoadingForPost(at indexPath: IndexPath) {
        postViewModels[indexPath.row].loadedPicture = nil
        if let pictureLoader = loadingOperations[indexPath] {
            pictureLoader.cancel()
            loadingOperations.removeValue(forKey: indexPath)
        }
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
                    self.postViewModels = []
                }
                self.previousSearch = tag
                
                DispatchQueue.main.async {
                    self.updatePostsAndTotalPages(with: response!, with: tag)
                }
                
            case .failure(let error):
                self.postViewModels = []
                DispatchQueue.main.async {
                    self.delegate?.postsDataViewModelFailedToGetPosts(with: tag)
                }
                print("Failed to get photos: ", error.localizedDescription)
            }
        }
    }
    
    func prefetchPosts(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            
            if let _ = loadingOperations[indexPath] {
                continue
            }
            
            if let pictureLoader = postViewModels[indexPath.row].loadPicture() {
                loadingQueue.addOperation(pictureLoader)
                loadingOperations[indexPath] = pictureLoader
            }
        }
    }
    
    func cancelPrefetching(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            if let pictureLoader = loadingOperations[indexPath] {
                pictureLoader.cancel()
                loadingOperations.removeValue(forKey: indexPath)
            }
        }
    }
    
    //MARK: - Helping Functions
    
    private func updatePostsAndTotalPages(with response: (posts: [Post], totalPages: Int),
                                           with tag: String? = nil) {
        let newPosts = response.posts
        var indexPaths = [IndexPath]()
        for row in postViewModels.count ..< postViewModels.count + newPosts.count {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        postViewModels += newPosts.map({ PostViewModel($0) })
        
        delegate?.postsDataViewModel(didAddNewPostsAt: indexPaths,
                                     totalPages: response.totalPages)
    }
    
}
