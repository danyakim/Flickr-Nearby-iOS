//
//  Post.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class Post {
    
    var title: String!
   
    var picture: Picture
    var user: User!
    
    init(title: String, ownerID: String, picture: Picture) {
        self.title = title
        self.user = User(id: ownerID)
        self.picture = picture
    }
    
}
