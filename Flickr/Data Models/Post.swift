//
//  Post.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class Post {

    var title: String!
   
    var pictureURL: URL!
    var highResPictureURL: URL!
    
    var user: User!
    
    init(title: String, pictureURL: URL, highResURL: URL) {
        self.title = title
        self.pictureURL = pictureURL
        self.highResPictureURL = highResURL
    }
    
}
