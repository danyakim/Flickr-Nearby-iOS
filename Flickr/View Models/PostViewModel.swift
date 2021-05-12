//
//  PostViewModel.swift
//  Flickr
//
//  Created by Daniil Kim on 12.05.2021.
//

import UIKit

struct PostViewModel {
    
    var loadedPicture: UIImage?
    
    let pictureURL: URL
    let highResURL: URL
    
    //Dependency Injection
    init(_ post: Post) {
        pictureURL = post.pictureURL
        highResURL = post.highResPictureURL
    }
    
    func loadPicture() -> LoadPictureOperation? {
        return loadedPicture == .none ? LoadPictureOperation(self) : nil
    }
}
