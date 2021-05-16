//
//  LoadPictureOperation.swift
//  Flickr
//
//  Created by Daniil Kim on 11.05.2021.
//

import UIKit

protocol LoadPictureOperationDelegate {
    func loadPictureOperation(finishedLoading image: UIImage, for url: URL)
}

class LoadPictureOperation: Operation {
    
    var loadingCompletionHandler: ((UIImage) -> ())?
    
    var delegate: LoadPictureOperationDelegate
    var pictureURL: URL
    
    init(for url: URL, delegate: LoadPictureOperationDelegate) {
        self.pictureURL = url
        self.delegate = delegate
    }
    
    override func main() {
        if isCancelled { return }
        
        var image: UIImage
        guard let imageData = try? Data(contentsOf: pictureURL) else { return }
        image = UIImage(data: imageData) ?? UIImage(systemName: "photo")!

        delegate.loadPictureOperation(finishedLoading: image, for: pictureURL)
        
        if isCancelled { return }
        
        if let loadingCompletionHandler = loadingCompletionHandler {
            loadingCompletionHandler(image)
        }
    }
}

