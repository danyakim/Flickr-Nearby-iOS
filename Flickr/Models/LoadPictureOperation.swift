//
//  LoadPictureOperation.swift
//  Flickr
//
//  Created by Daniil Kim on 11.05.2021.
//

import UIKit

class LoadPictureOperation: Operation {
    
    var loadedPicture: UIImage?
    var loadingCompletionHandler: ((PostViewModel) -> ())?
    
    var postViewModel: PostViewModel
    
    init(_ postViewModel: PostViewModel) {
        self.postViewModel = postViewModel
    }
    
    override func main() {
        if isCancelled { return }
        
        var image: UIImage
        guard let imageData = try? Data(contentsOf: postViewModel.pictureURL) else { return }
        image = UIImage(data: imageData)!
        
        loadedPicture = image
        postViewModel.loadedPicture = image
        
        if isCancelled { return }
        
        if let loadingCompletionHandler = loadingCompletionHandler {
            DispatchQueue.main.async {
                loadingCompletionHandler(self.postViewModel)
            }
        }
    }
}

