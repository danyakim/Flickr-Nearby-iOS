//
//  LoadPictureOperation.swift
//  Flickr
//
//  Created by Daniil Kim on 11.05.2021.
//

import UIKit

class LoadPictureOperation: Operation {
    
    var loadedPicture: UIImage?
    var loadingCompletionHandler: ((Post) -> ())?
    
    let post: Post
    
    init(_ post: Post) {
        self.post = post
    }
    
    override func main() {
        if isCancelled { return }
        
        var image: UIImage
        guard let imageData = try? Data(contentsOf: post.pictureURL) else { return }
        image = UIImage(data: imageData)!
        
        loadedPicture = image
        post.loadedPicture = loadedPicture
        
        if let loadingCompletionHandler = loadingCompletionHandler {
            DispatchQueue.main.async {
                loadingCompletionHandler(self.post)
            }
        }
    }
}

