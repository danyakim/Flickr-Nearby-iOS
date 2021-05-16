//
//  ImageLoader.swift
//  Flickr
//
//  Created by Daniil Kim on 14.05.2021.
//

import Foundation
import UIKit

class ImageLoader {
    
    //MARK: - Properties
    
    private var imageCache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 200
        return cache
    }()
    
    private var loadingQueue = OperationQueue()
    private var loadingOperations: [URL: LoadPictureOperation] = [:]
    
    //MARK: - Methods
    
    func getImage(at url: URL, completion: @escaping (UIImage) -> ()) {
        if let pictureLoader = loadingOperations[url] {
            if let cachedImage = imageCache.object(forKey: url as NSURL) {
                completion(cachedImage)
            } else {
                pictureLoader.loadingCompletionHandler = completion
            }
            
        } else {
            if let pictureLoader = createPictureLoader(for: url) {
                pictureLoader.loadingCompletionHandler = completion
                loadingQueue.addOperation(pictureLoader)
                loadingOperations[url] = pictureLoader
            } else {
                if let cachedImage = imageCache.object(forKey: url as NSURL) {
                    completion(cachedImage)
                }
            }
            
        }
    }
    
    func cancelLoading(for url: URL) {
        if let pictureLoader = loadingOperations[url] {
            pictureLoader.cancel()
            loadingOperations.removeValue(forKey: url)
        }
    }
    
    func startLoadingImages(at urls: [URL]) {
        for url in urls {
            if let _ = loadingOperations[url] {
                continue
            }
            
            if let pictureLoader = createPictureLoader(for: url) {
                loadingQueue.addOperation(pictureLoader)
                loadingOperations[url] = pictureLoader
            }
        }
    }
    
    func cancelLoadingImages(at urls: [URL]) {
        for url in urls {
            if let pictureLoader = loadingOperations[url] {
                pictureLoader.cancel()
                loadingOperations.removeValue(forKey: url)
            }
        }
    }
    
    //MARK: - Private Methods
    
    private func createPictureLoader(for url: URL) -> LoadPictureOperation? {
        if imageCache.object(forKey: url as NSURL) != nil { return nil }
        return LoadPictureOperation(for: url, delegate: self)
    }
    
}

//MARK: - LoadPictureOperation Delegate

extension ImageLoader: LoadPictureOperationDelegate {
    
    func loadPictureOperation(finishedLoading image: UIImage, for url: URL) {
        imageCache.setObject(image, forKey: url as NSURL)
        loadingOperations.removeValue(forKey: url)
    }
    
}
