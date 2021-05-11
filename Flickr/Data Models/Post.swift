//
//  Post.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class Post {
    
    var loadedPicture: UIImage?
    
    var pictureURL: URL!
    var highResPictureURL: URL!
    
    init(pictureURL: URL, highResURL: URL) {
        self.pictureURL = pictureURL
        self.highResPictureURL = highResURL
    }
    
    func loadPicture() -> LoadPictureOperation? {
        if let _ = loadedPicture {
            return nil
        } else {
            return LoadPictureOperation(self)
        }
    }
    
}
