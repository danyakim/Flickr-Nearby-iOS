//
//  Post.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

struct Post {
    
    var pictureURL: URL
    var highResPictureURL: URL
    
    init(pictureURL: URL, highResURL: URL) {
        self.pictureURL = pictureURL
        self.highResPictureURL = highResURL
    }
}
